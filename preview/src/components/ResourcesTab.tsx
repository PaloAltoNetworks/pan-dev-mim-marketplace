import React, { useState } from 'react';
import { ResourceCollection, Video, SolutionGuide, ExternalLink, OtherResource } from '../types';

interface ResourcesTabProps {
    resources?: ResourceCollection;
}

// Helper function to extract YouTube video ID from URL
function getYouTubeVideoId(url: string): string | null {
    const patterns = [
        /youtube\.com\/watch\?v=([^&]+)/,
        /youtu\.be\/([^?]+)/,
        /youtube\.com\/embed\/([^?]+)/
    ];

    for (const pattern of patterns) {
        const match = url.match(pattern);
        if (match) return match[1];
    }
    return null;
}

// Helper function to extract Vimeo video ID from URL
function getVimeoVideoId(url: string): string | null {
    const match = url.match(/vimeo\.com\/(\d+)/);
    return match ? match[1] : null;
}

// Helper function to get video thumbnail URL
function getVideoThumbnail(video: Video): string {
    if (video.thumbnailUrl) return video.thumbnailUrl;

    if (video.platform === 'youtube' || video.url.includes('youtube.com') || video.url.includes('youtu.be')) {
        const videoId = getYouTubeVideoId(video.url);
        if (videoId) return `https://img.youtube.com/vi/${videoId}/maxresdefault.jpg`;
    }

    // Vimeo thumbnails require API call, use placeholder
    if (video.platform === 'vimeo' || video.url.includes('vimeo.com')) {
        return 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="640" height="360"%3E%3Crect fill="%23ddd" width="640" height="360"/%3E%3Ctext fill="%23999" font-family="sans-serif" font-size="24" x="50%25" y="50%25" text-anchor="middle"%3EVimeo Video%3C/text%3E%3C/svg%3E';
    }

    // Generic placeholder
    return 'data:image/svg+xml,%3Csvg xmlns="http://www.w3.org/2000/svg" width="640" height="360"%3E%3Crect fill="%23ddd" width="640" height="360"/%3E%3Ctext fill="%23999" font-family="sans-serif" font-size="24" x="50%25" y="50%25" text-anchor="middle"%3EVideo%3C/text%3E%3C/svg%3E';
}

// Helper function to get video embed URL
function getVideoEmbedUrl(video: Video): string | null {
    const youtubeId = getYouTubeVideoId(video.url);
    if (youtubeId) {
        return `https://www.youtube-nocookie.com/embed/${youtubeId}?rel=0&modestbranding=1`;
    }

    const vimeoId = getVimeoVideoId(video.url);
    if (vimeoId) {
        return `https://player.vimeo.com/video/${vimeoId}`;
    }

    return null;
}

// Helper function to get file type icon
function getFileTypeIcon(type: string): string {
    switch (type) {
        case 'pdf': return '📄';
        case 'whitepaper': return '📋';
        case 'doc': return '📝';
        default: return '📦';
    }
}

export default function ResourcesTab({ resources }: ResourcesTabProps): React.JSX.Element {
    const [activeVideoIndex, setActiveVideoIndex] = useState(0);

    const hasVideos = resources?.videos && resources.videos.length > 0;

    // Backward compatibility: merge old structure into new
    const consolidatedOtherResources: OtherResource[] = [
        ...(resources?.otherResources ?? []),
        ...(resources?.solutionGuides?.map(g => ({ ...g, resourceType: 'file' as const })) ?? []),
        ...(resources?.externalLinks?.map(l => ({ ...l, resourceType: 'link' as const })) ?? [])
    ];

    const hasOtherResources = consolidatedOtherResources.length > 0;

    if (!hasVideos && !hasOtherResources) {
        return (
            <div className="resources-empty-state">
                No resources available for this product
            </div>
        );
    }

    return (
        <div className="resources-tab">
                {/* Videos Section */}
                {hasVideos && (() => {
                    const embeddableVideos = resources.videos!.filter(video => getVideoEmbedUrl(video) !== null);
                    const hasMultipleVideos = embeddableVideos.length >= 2;
                    const shouldShowGallery = embeddableVideos.length > 0;

                    // Warn if some videos can't be embedded
                    if (embeddableVideos.length < resources.videos!.length) {
                        console.warn('Some videos could not be embedded and are not shown in the gallery');
                    }

                    return (
                        <div className="resources-section">
                            <h2 className="resources-section-title">Videos</h2>

                            {shouldShowGallery ? (
                                <div className="resources-video-gallery">
                                    {/* Active Video Player */}
                                    <div className="resources-video-player">
                                        {(() => {
                                            const activeVideo = embeddableVideos[activeVideoIndex];
                                            const embedUrl = getVideoEmbedUrl(activeVideo);
                                            return (
                                                <>
                                                    <div className="resources-video-embed">
                                                        <iframe
                                                            src={embedUrl!}
                                                            title={activeVideo.title}
                                                            frameBorder="0"
                                                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                                            allowFullScreen
                                                        />
                                                    </div>
                                                    <div className="resources-video-info">
                                                        <h3 className="resources-video-player-title">
                                                            {activeVideo.title}
                                                        </h3>
                                                        {activeVideo.description && (
                                                            <p className="resources-video-player-description">
                                                                {activeVideo.description}
                                                            </p>
                                                        )}
                                                        <a
                                                            href={activeVideo.url}
                                                            target="_blank"
                                                            rel="noopener noreferrer"
                                                            className="resources-video-external-link"
                                                        >
                                                            Watch on {activeVideo.platform === 'vimeo' ? 'Vimeo' : 'YouTube'} →
                                                        </a>
                                                    </div>
                                                </>
                                            );
                                        })()}
                                    </div>

                                    {/* Thumbnail Gallery (only show if 2+ videos) */}
                                    {hasMultipleVideos && (
                                        <div className="resources-video-thumbnails">
                                            {embeddableVideos.map((video, idx) => (
                                                <button
                                                    key={idx}
                                                    className={`resources-video-thumbnail-btn ${idx === activeVideoIndex ? 'active' : ''}`}
                                                    onClick={() => setActiveVideoIndex(idx)}
                                                    aria-label={`Play ${video.title}`}
                                                >
                                                    <img
                                                        src={getVideoThumbnail(video)}
                                                        alt={video.title}
                                                        className="resources-video-thumbnail-img"
                                                    />
                                                    <div className="resources-video-thumbnail-overlay">
                                                        <svg className="resources-video-play-icon" viewBox="0 0 24 24" fill="white">
                                                            <path d="M8 5v14l11-7z"/>
                                                        </svg>
                                                    </div>
                                                    <div className="resources-video-thumbnail-title">{video.title}</div>
                                                </button>
                                            ))}
                                        </div>
                                    )}
                                </div>
                            ) : (
                                // Fallback: Original card grid for non-embeddable videos
                                <div className="resources-videos-grid">
                                    {resources.videos!.map((video, idx) => (
                                        <a
                                            key={idx}
                                            href={video.url}
                                            target="_blank"
                                            rel="noopener noreferrer"
                                            className="resource-video-card"
                                        >
                                            <img
                                                src={getVideoThumbnail(video)}
                                                alt={video.title}
                                                className="resource-video-thumbnail"
                                            />
                                            <div className="resource-video-content">
                                                <div className="resource-video-title">{video.title}</div>
                                                {video.description && (
                                                    <div className="resource-video-description">
                                                        {video.description}
                                                    </div>
                                                )}
                                            </div>
                                        </a>
                                    ))}
                                </div>
                            )}
                        </div>
                    );
                })()}

                {/* Other Resources Section - Consolidated */}
                {hasOtherResources && (
                    <div className="resources-section">
                        <h2 className="resources-section-title">Other Resources</h2>
                        <ul className="resources-other-list">
                            {consolidatedOtherResources.map((resource, idx) => (
                                <li key={idx} className="resource-other-item">
                                    <a href={resource.url} target="_blank" rel="noopener noreferrer">
                                        <div className="resource-other-content">
                                            <span className="resource-other-icon">
                                                {resource.resourceType === 'file' ? '📄' : '🔗'}
                                            </span>
                                            <div>
                                                <div className="resource-other-title">{resource.title}</div>
                                                {resource.description && (
                                                    <div className="resource-other-description">
                                                        {resource.description}
                                                    </div>
                                                )}
                                                {resource.resourceType === 'file' && 'type' in resource && resource.type && (
                                                    <span className="resource-other-type">
                                                        {resource.type.toUpperCase()}
                                                    </span>
                                                )}
                                            </div>
                                        </div>
                                    </a>
                                </li>
                            ))}
                        </ul>
                    </div>
                )}
            </div>
    );
}
