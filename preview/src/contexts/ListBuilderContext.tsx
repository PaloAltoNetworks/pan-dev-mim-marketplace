import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';
import { IntegrationMetadata } from '../types';
import {
  SavedList,
  getListFromLocalStorage,
  saveListToLocalStorage,
  clearListFromLocalStorage,
  createNewList,
  updateListTimestamp,
  decodeListFromUrl,
} from '../utils/listUtils';

interface ListBuilderContextType {
  currentList: SavedList | null;
  integrations: IntegrationMetadata[];
  addIntegration: (integration: IntegrationMetadata) => void;
  removeIntegration: (integrationName: string) => void;
  reorderIntegrations: (startIndex: number, endIndex: number) => void;
  clearList: () => void;
  updateListName: (name: string) => void;
  isInList: (integrationName: string) => boolean;
  loadListFromUrl: (encodedList: string) => void;
  setIntegrationsData: (integrations: IntegrationMetadata[]) => void;
}

const ListBuilderContext = createContext<ListBuilderContextType | undefined>(undefined);

export function ListBuilderProvider({ children }: { children: React.ReactNode }) {
  const [currentList, setCurrentList] = useState<SavedList | null>(null);
  const [integrationsData, setIntegrationsData] = useState<IntegrationMetadata[]>([]);

  // Initialize list from localStorage on mount
  useEffect(() => {
    const stored = getListFromLocalStorage();
    if (stored) {
      setCurrentList(stored);
    } else {
      setCurrentList(createNewList());
    }
  }, []);

  // Save to localStorage whenever list changes
  useEffect(() => {
    if (currentList) {
      saveListToLocalStorage(currentList);
    }
  }, [currentList]);

  const addIntegration = useCallback((integration: IntegrationMetadata) => {
    setCurrentList((prev) => {
      if (!prev) return prev;

      // Prevent duplicates
      if (prev.integrationIds.includes(integration.name)) {
        return prev;
      }

      const updated = {
        ...prev,
        integrationIds: [...prev.integrationIds, integration.name],
      };

      return updateListTimestamp(updated);
    });
  }, []);

  const removeIntegration = useCallback((integrationName: string) => {
    setCurrentList((prev) => {
      if (!prev) return prev;

      const updated = {
        ...prev,
        integrationIds: prev.integrationIds.filter((id) => id !== integrationName),
      };

      return updateListTimestamp(updated);
    });
  }, []);

  const reorderIntegrations = useCallback((startIndex: number, endIndex: number) => {
    setCurrentList((prev) => {
      if (!prev) return prev;

      const ids = [...prev.integrationIds];
      const [removed] = ids.splice(startIndex, 1);
      ids.splice(endIndex, 0, removed);

      const updated = {
        ...prev,
        integrationIds: ids,
      };

      return updateListTimestamp(updated);
    });
  }, []);

  const clearList = useCallback(() => {
    setCurrentList((prev) => {
      if (!prev) return prev;

      const updated = {
        ...prev,
        integrationIds: [],
      };

      return updateListTimestamp(updated);
    });
  }, []);

  const updateListName = useCallback((name: string) => {
    setCurrentList((prev) => {
      if (!prev) return prev;

      const updated = {
        ...prev,
        name,
      };

      return updateListTimestamp(updated);
    });
  }, []);

  const isInList = useCallback(
    (integrationName: string): boolean => {
      return currentList?.integrationIds.includes(integrationName) || false;
    },
    [currentList]
  );

  const loadListFromUrl = useCallback((encodedList: string) => {
    const decoded = decodeListFromUrl(encodedList);
    if (decoded) {
      setCurrentList(decoded);
    }
  }, []);

  const setIntegrationsDataCallback = useCallback((integrations: IntegrationMetadata[]) => {
    setIntegrationsData(integrations);
  }, []);

  // Get full integration objects from IDs
  const integrations = React.useMemo(() => {
    if (!currentList || !integrationsData.length) return [];

    return currentList.integrationIds
      .map((id) => integrationsData.find((int) => int.name === id))
      .filter((int): int is IntegrationMetadata => int !== undefined);
  }, [currentList, integrationsData]);

  const value: ListBuilderContextType = {
    currentList,
    integrations,
    addIntegration,
    removeIntegration,
    reorderIntegrations,
    clearList,
    updateListName,
    isInList,
    loadListFromUrl,
    setIntegrationsData: setIntegrationsDataCallback,
  };

  return (
    <ListBuilderContext.Provider value={value}>
      {children}
    </ListBuilderContext.Provider>
  );
}

export function useListBuilder() {
  const context = useContext(ListBuilderContext);
  if (context === undefined) {
    throw new Error('useListBuilder must be used within a ListBuilderProvider');
  }
  return context;
}
