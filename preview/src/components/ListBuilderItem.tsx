import React, { useState } from 'react';
import { IntegrationMetadata } from '../types';
import Link from '@docusaurus/Link';

interface ListBuilderItemProps {
  integration: IntegrationMetadata;
  onRemove: () => void;
  index: number;
  onDragStart: (index: number) => void;
  onDragOver: (index: number) => void;
  onDragEnd: () => void;
}

export default function ListBuilderItem({
  integration,
  onRemove,
  index,
  onDragStart,
  onDragOver,
  onDragEnd,
}: ListBuilderItemProps) {
  const [isDragging, setIsDragging] = useState(false);

  const handleDragStart = (e: React.DragEvent) => {
    setIsDragging(true);
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/plain', index.toString());
    onDragStart(index);
  };

  const handleDragEnd = () => {
    setIsDragging(false);
    onDragEnd();
  };

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    onDragOver(index);
  };

  return (
    <div
      className={`list-builder-item${isDragging ? ' dragging' : ''}`}
      draggable
      onDragStart={handleDragStart}
      onDragEnd={handleDragEnd}
      onDragOver={handleDragOver}
    >
      <div className="list-builder-item-drag-handle" title="Drag to reorder">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
          <path d="M9 3h2v2H9V3zm0 4h2v2H9V7zm0 4h2v2H9v-2zm0 4h2v2H9v-2zm0 4h2v2H9v-2zm4-16h2v2h-2V3zm0 4h2v2h-2V7zm0 4h2v2h-2v-2zm0 4h2v2h-2v-2zm0 4h2v2h-2v-2z" />
        </svg>
      </div>

      <div className="list-builder-item-content">
        <Link
          to={`/marketplace/${integration.name.replace(/[^a-zA-Z0-9]/g, '')}`}
          className="list-builder-item-title"
        >
          {integration.name}
        </Link>
        <div className="list-builder-item-meta">
          v{integration.currentVersion} • {integration.author}
        </div>
      </div>

      <button
        className="list-builder-item-delete"
        onClick={onRemove}
        aria-label={`Remove ${integration.name} from list`}
        title="Remove from list"
      >
        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
          <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z" />
        </svg>
      </button>
    </div>
  );
}
