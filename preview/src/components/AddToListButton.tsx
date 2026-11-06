import React, { useState, useEffect } from 'react';
import { IntegrationMetadata } from '../types';
import { useListBuilder } from '../contexts/ListBuilderContext';

interface AddToListButtonProps {
  integration: IntegrationMetadata;
}

export default function AddToListButton({ integration }: AddToListButtonProps) {
  const { addIntegration, removeIntegration, isInList } = useListBuilder();
  const [isAdding, setIsAdding] = useState(false);
  const inList = isInList(integration.name);

  useEffect(() => {
    if (isAdding) {
      const timer = setTimeout(() => setIsAdding(false), 300);
      return () => clearTimeout(timer);
    }
  }, [isAdding]);

  const handleClick = () => {
    if (inList) {
      removeIntegration(integration.name);
    } else {
      addIntegration(integration);
      setIsAdding(true);
    }
  };

  return (
    <button
      onClick={handleClick}
      className={`add-to-list-btn ${inList ? 'add-to-list-btn--added' : ''} ${isAdding ? 'add-to-list-btn--adding' : ''}`}
      aria-label={inList ? 'Remove from list' : 'Add to list'}
      title={inList ? 'Click to remove from list' : 'Add to your list'}
    >
      <span className="add-to-list-btn-icon">
        {inList ? (
          // Checkmark icon
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path
              d="M13.3334 4L6.00002 11.3333L2.66669 8"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        ) : (
          // Plus icon
          <svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path
              d="M8 3.33334V12.6667M3.33334 8H12.6667"
              stroke="currentColor"
              strokeWidth="2"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          </svg>
        )}
      </span>
      <span className="add-to-list-btn-text">
        {inList ? 'In List' : 'Add to List'}
      </span>
    </button>
  );
}
