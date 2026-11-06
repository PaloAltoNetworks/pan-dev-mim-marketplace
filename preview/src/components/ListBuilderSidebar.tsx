import React, { useState, useEffect } from 'react';
import { useListBuilder } from '../contexts/ListBuilderContext';
import ListBuilderItem from './ListBuilderItem';
import ShareListButton from './ShareListButton';
import AddToListButton from './AddToListButton';
import { IntegrationMetadata } from '../types';

interface ListBuilderSidebarProps {
  isCollapsed: boolean;
  onToggleCollapsed: () => void;
  currentIntegration?: IntegrationMetadata;
}

export default function ListBuilderSidebar({ isCollapsed, onToggleCollapsed, currentIntegration }: ListBuilderSidebarProps) {
  const {
    currentList,
    integrations,
    removeIntegration,
    reorderIntegrations,
    clearList,
    updateListName,
    addIntegration,
    isInList,
  } = useListBuilder();

  const [isEditing, setIsEditing] = useState(false);
  const [editedName, setEditedName] = useState(currentList?.name || '');
  const [draggedIndex, setDraggedIndex] = useState<number | null>(null);
  const [isDragOver, setIsDragOver] = useState(false);

  if (!currentList) return null;

  const handleNameClick = () => {
    setIsEditing(true);
    setEditedName(currentList.name);
  };

  const handleNameBlur = () => {
    setIsEditing(false);
    if (editedName.trim()) {
      updateListName(editedName.trim());
    } else {
      setEditedName(currentList.name);
    }
  };

  const handleNameKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter') {
      handleNameBlur();
    } else if (e.key === 'Escape') {
      setIsEditing(false);
      setEditedName(currentList.name);
    }
  };

  const handleDragStart = (index: number) => {
    setDraggedIndex(index);
  };

  const handleDragOver = (index: number) => {
    if (draggedIndex === null || draggedIndex === index) return;

    reorderIntegrations(draggedIndex, index);
    setDraggedIndex(index);
  };

  const handleDragEnd = () => {
    setDraggedIndex(null);
  };

  // Handle external drops (from marketplace grid)
  const handleExternalDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDragOver(false);

    try {
      const data = e.dataTransfer.getData('application/json');
      if (data) {
        const integration = JSON.parse(data) as IntegrationMetadata;
        if (!isInList(integration.name)) {
          addIntegration(integration);
        }
      }
    } catch (error) {
      console.error('Failed to add integration from drop:', error);
    }
  };

  const handleExternalDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'copy';
    setIsDragOver(true);
  };

  const handleExternalDragLeave = () => {
    setIsDragOver(false);
  };

  if (!currentList || isCollapsed) return null;

  return (
    <aside
      className={`list-builder-sidebar${isDragOver ? ' drag-over' : ''}`}
      onDrop={handleExternalDrop}
      onDragOver={handleExternalDragOver}
      onDragLeave={handleExternalDragLeave}
    >
      <div className="list-builder-header">
        <div className="list-builder-header-top">
          {isEditing ? (
            <input
              type="text"
              className="list-builder-title-input"
              value={editedName}
              onChange={(e) => setEditedName(e.target.value)}
              onBlur={handleNameBlur}
              onKeyDown={handleNameKeyDown}
              autoFocus
              maxLength={50}
            />
          ) : (
            <h3
              className="list-builder-title"
              onClick={handleNameClick}
              title="Click to edit"
            >
              {currentList.name}
            </h3>
          )}

          <div className="list-builder-header-controls">
            <button
              className="list-builder-collapse-btn"
              onClick={onToggleCollapsed}
              title="Collapse sidebar"
              aria-label="Collapse sidebar"
            >
              <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
                <path d="M15.41 16.59L10.83 12l4.58-4.59L14 6l-6 6 6 6 1.41-1.41z" />
              </svg>
            </button>
          </div>
        </div>

        <div className="list-builder-count">
          {integrations.length} {integrations.length === 1 ? 'item' : 'items'}
        </div>
      </div>

      <div className="list-builder-actions">
        <ShareListButton list={currentList} disabled={integrations.length === 0} />
        <button
          className="list-builder-clear-btn"
          onClick={clearList}
          disabled={integrations.length === 0}
          title="Clear all items"
        >
          Clear All
        </button>
      </div>

      <div className="list-builder-items">
        {currentIntegration && (
          <div className="list-builder-add-section">
            <AddToListButton integration={currentIntegration} />
          </div>
        )}

        {integrations.length === 0 ? (
          !currentIntegration && (
            <div className="list-builder-empty-state">
              <svg
                width="48"
                height="48"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="1.5"
              >
                <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                <path d="M9 12h6m-6 4h6" />
              </svg>
              <p>Drag integrations here to build your list</p>
              <small>Or browse and search to find integrations</small>
            </div>
          )
        ) : (
          integrations.map((integration, index) => (
            <ListBuilderItem
              key={integration.name}
              integration={integration}
              onRemove={() => removeIntegration(integration.name)}
              index={index}
              onDragStart={handleDragStart}
              onDragOver={handleDragOver}
              onDragEnd={handleDragEnd}
            />
          ))
        )}
      </div>
    </aside>
  );
}
