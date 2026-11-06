import { IntegrationMetadata } from '../types';

export interface SavedList {
  id: string;
  name: string;
  integrationIds: string[];
  createdAt: string;
  updatedAt: string;
}

const STORAGE_KEY = 'mim-marketplace-list';

/**
 * Get the current list from localStorage
 */
export function getListFromLocalStorage(): SavedList | null {
  if (typeof window === 'undefined') return null;

  try {
    const stored = localStorage.getItem(STORAGE_KEY);
    if (!stored) return null;
    return JSON.parse(stored) as SavedList;
  } catch (error) {
    console.error('Failed to load list from localStorage:', error);
    return null;
  }
}

/**
 * Save the current list to localStorage
 */
export function saveListToLocalStorage(list: SavedList): void {
  if (typeof window === 'undefined') return;

  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(list));
  } catch (error) {
    console.error('Failed to save list to localStorage:', error);
  }
}

/**
 * Clear the list from localStorage
 */
export function clearListFromLocalStorage(): void {
  if (typeof window === 'undefined') return;

  try {
    localStorage.removeItem(STORAGE_KEY);
  } catch (error) {
    console.error('Failed to clear list from localStorage:', error);
  }
}

/**
 * Encode a list to a base64 URL parameter
 */
export function encodeListToUrl(list: SavedList): string {
  try {
    const json = JSON.stringify({
      name: list.name,
      ids: list.integrationIds,
    });
    return btoa(json);
  } catch (error) {
    console.error('Failed to encode list:', error);
    return '';
  }
}

/**
 * Decode a list from a base64 URL parameter
 */
export function decodeListFromUrl(encoded: string): SavedList | null {
  try {
    const json = atob(encoded);
    const data = JSON.parse(json);

    if (!data.ids || !Array.isArray(data.ids)) {
      return null;
    }

    return {
      id: generateId(),
      name: data.name || 'Shared List',
      integrationIds: data.ids,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
  } catch (error) {
    console.error('Failed to decode list from URL:', error);
    return null;
  }
}

/**
 * Generate a shareable URL for the current list
 */
export function generateShareableUrl(list: SavedList): string {
  if (typeof window === 'undefined') return '';

  const encoded = encodeListToUrl(list);
  const baseUrl = window.location.origin + window.location.pathname;
  return `${baseUrl}?list=${encoded}`;
}

/**
 * Create a new empty list
 */
export function createNewList(name: string = 'My Integration List'): SavedList {
  return {
    id: generateId(),
    name,
    integrationIds: [],
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
}

/**
 * Generate a unique ID
 */
function generateId(): string {
  return `list-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Update a list's timestamp
 */
export function updateListTimestamp(list: SavedList): SavedList {
  return {
    ...list,
    updatedAt: new Date().toISOString(),
  };
}
