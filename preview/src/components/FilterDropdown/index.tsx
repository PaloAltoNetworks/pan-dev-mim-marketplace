import React, { useState } from 'react';
import './styles.module.css';

export interface FilterDropdownProps {
  title: string;
  items: string[];
  selected: string[];
  onToggle: (value: string) => void;
  counts?: Record<string, number>;
  defaultOpen?: boolean;
}

const SEARCHABLE_THRESHOLD = 8;
// Long facets (Developer has ~100 entries) collapse to this many rows behind a "Show more"
// link, so every section stays visible in the rail instead of one of them eating the scroll.
const INITIAL_VISIBLE = 6;

export default function FilterDropdown({
  title,
  items,
  selected,
  onToggle,
  counts = {},
  defaultOpen = true,
}: FilterDropdownProps) {
  const [open, setOpen] = useState(defaultOpen);
  const [expanded, setExpanded] = useState(false);
  const [query, setQuery] = useState('');

  const searchable = items.length > SEARCHABLE_THRESHOLD;
  const filtering = searchable && query.trim().length > 0;

  const matches = filtering
    ? items.filter((i) => i.toLowerCase().includes(query.trim().toLowerCase()))
    : items;

  // Searching or expanding shows everything. Otherwise show the first slice — plus any
  // checked item that falls outside it, so an active filter is always visible to uncheck.
  const visibleItems =
    expanded || filtering
      ? matches
      : [
          ...matches.slice(0, INITIAL_VISIBLE),
          ...matches.slice(INITIAL_VISIBLE).filter((i) => selected.includes(i)),
        ];

  const hiddenCount = matches.length - visibleItems.length;
  const showToggle = !filtering && (hiddenCount > 0 || expanded);

  return (
    <div className="filter-dropdown">
      <button
        className="filter-dropdown-header"
        onClick={() => setOpen((o) => !o)}
        aria-expanded={open}
      >
        <span className="filter-section-label">
          {title} <span className="filter-count">({items.length})</span>
        </span>
        <span className={`filter-dropdown-chevron${open ? " open" : ""}`}>▾</span>
      </button>
      {open && (
        <>
          {searchable && (
            <input
              type="text"
              className="filter-dropdown-search"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder={`Filter ${title.toLowerCase()}…`}
              aria-label={`Filter ${title}`}
            />
          )}
          <div
            className={`filter-dropdown-list${expanded || filtering ? " scrollable" : ""}`}
          >
            {visibleItems.length === 0 ? (
              <div className="filter-dropdown-empty">No matches</div>
            ) : (
              visibleItems.map((item) => (
                <label key={item} className="filter-checkbox-label">
                  <input
                    type="checkbox"
                    checked={selected.includes(item)}
                    onChange={() => onToggle(item)}
                  />
                  <span className="filter-checkbox-text">
                    {item}
                    {counts[item] !== undefined && (
                      <span className="filter-count"> ({counts[item]})</span>
                    )}
                  </span>
                </label>
              ))
            )}
          </div>
          {showToggle && (
            <button
              className="filter-show-more"
              onClick={() => setExpanded((e) => !e)}
              aria-expanded={expanded}
            >
              {expanded ? 'Show less' : `Show more (${hiddenCount})`}
            </button>
          )}
        </>
      )}
    </div>
  );
}
