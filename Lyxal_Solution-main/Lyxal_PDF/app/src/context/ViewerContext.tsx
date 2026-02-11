import React, { createContext, useContext, useReducer, ReactNode } from 'react';

// -- Types --
interface ViewerState {
  pdfDoc: any | null; // PDFDocumentProxy from pdf.js
  currentPage: number;
  scale: number;
  rotation: number;
  isSidebarOpen: boolean;
  totalPages: number;
  outline: any[] | null;
  scaleMode: 'custom' | 'page-width' | 'page-height';
  search: {
      isOpen: boolean;
      query: string;
      matches: { pageNum: number; matchIdx: number }[]; // matchIdx is index in textItems array? No, string index.
      currentMatch: number; // Index in matches array
  };
}

type Action =
  | { type: 'SET_DOC'; payload: any }
  | { type: 'SET_PAGE'; payload: number }
  | { type: 'SET_SCALE'; payload: number }
  | { type: 'AUTO_SCALE'; payload: number }
  | { type: 'SET_SCALE_MODE'; payload: 'custom' | 'page-width' | 'page-height' }
  | { type: 'ROTATE_CW' }
  | { type: 'TOGGLE_SIDEBAR' }
  | { type: 'SET_OUTLINE'; payload: any[] }
  | { type: 'TOGGLE_SEARCH' }
  | { type: 'SET_SEARCH_QUERY'; payload: string }
  | { type: 'SET_SEARCH_MATCHES'; payload: any[] }
  | { type: 'NEXT_MATCH' }
  | { type: 'PREV_MATCH' };

// -- Reducer --
const initialState: ViewerState = {
  pdfDoc: null,
  currentPage: 1,
  scale: 1.0, // 1.0 = 100%
  rotation: 0,
  isSidebarOpen: true,
  totalPages: 0,
  outline: null,
  scaleMode: 'custom',
  search: {
      isOpen: false,
      query: '',
      matches: [],
      currentMatch: -1
  }
};

function viewerReducer(state: ViewerState, action: Action): ViewerState {
  switch (action.type) {
    case 'SET_DOC':
      return { ...state, pdfDoc: action.payload, totalPages: action.payload.numPages, currentPage: 1, outline: null, scaleMode: 'page-width' }; 
    case 'SET_PAGE':
      const newPage = Math.max(1, Math.min(action.payload, state.totalPages));
      return { ...state, currentPage: newPage };
    case 'SET_SCALE':
      return { ...state, scale: action.payload, scaleMode: 'custom' }; 
    case 'AUTO_SCALE':
      return { ...state, scale: action.payload }; 
    case 'SET_SCALE_MODE':
      return { ...state, scaleMode: action.payload };
    case 'ROTATE_CW':
      return { ...state, rotation: (state.rotation + 90) % 360 };
    case 'TOGGLE_SIDEBAR':
      return { ...state, isSidebarOpen: !state.isSidebarOpen };
    case 'SET_OUTLINE':
      return { ...state, outline: action.payload };
      
    // Search Actions
    case 'TOGGLE_SEARCH':
        return { ...state, search: { ...state.search, isOpen: !state.search.isOpen } };
    case 'SET_SEARCH_QUERY':
        return { ...state, search: { ...state.search, query: action.payload } };
    case 'SET_SEARCH_MATCHES':
        return { ...state, search: { ...state.search, matches: action.payload, currentMatch: action.payload.length > 0 ? 0 : -1 } };
    case 'NEXT_MATCH':
        if (state.search.matches.length === 0) return state;
        return { ...state, search: { ...state.search, currentMatch: (state.search.currentMatch + 1) % state.search.matches.length } };
    case 'PREV_MATCH':
        if (state.search.matches.length === 0) return state;
        return { ...state, search: { ...state.search, currentMatch: (state.search.currentMatch - 1 + state.search.matches.length) % state.search.matches.length } };
        
    default:
      return state;
  }
}

// -- Context --
const ViewerContext = createContext<{
  state: ViewerState;
  dispatch: React.Dispatch<Action>;
} | undefined>(undefined);

export const ViewerProvider = ({ children }: { children: ReactNode }) => {
  const [state, dispatch] = useReducer(viewerReducer, initialState);
  return (
    <ViewerContext.Provider value={{ state, dispatch }}>
      {children}
    </ViewerContext.Provider>
  );
};

// -- Hook --
export const useViewer = () => {
  const context = useContext(ViewerContext);
  if (!context) throw new Error('useViewer must be used within a ViewerProvider');
  return context;
};

