import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import CssBaseline from '@mui/material/CssBaseline';
import { QueryClient, QueryClientProvider } from 'react-query';

// Pages
import Home from './pages/Home';
import Login from './pages/Login';
import Register from './pages/Register';
import Profile from './pages/Profile';

const theme = createTheme({
  palette: {
    primary: {
      main: '#000091', // Bleu Marianne
      light: '#6A6AF4',
      dark: '#000091',
      contrastText: '#ffffff',
    },
    secondary: {
      main: '#E1000F', // Rouge Marianne
      light: '#FF4D4D',
      dark: '#E1000F',
      contrastText: '#ffffff',
    },
    info: {
      main: '#009099', // Vert Marianne
      light: '#009099',
      dark: '#009099',
      contrastText: '#ffffff',
    },
    grey: {
      900: '#3A3A3A', // Gris Marianne
    },
    background: {
      default: '#f5f5f5',
      paper: '#ffffff',
    },
  },
  typography: {
    fontFamily: '"Marianne", "Roboto", "Helvetica", "Arial", sans-serif',
    h1: {
      fontWeight: 700,
      color: '#000091',
    },
    h2: {
      fontWeight: 600,
      color: '#000091',
    },
    h3: {
      fontWeight: 600,
      color: '#000091',
    },
    h4: {
      fontWeight: 600,
      color: '#000091',
    },
    h5: {
      fontWeight: 500,
      color: '#000091',
    },
    h6: {
      fontWeight: 500,
      color: '#000091',
    },
    button: {
      textTransform: 'none',
      fontWeight: 500,
    },
  },
  components: {
    MuiButton: {
      styleOverrides: {
        root: {
          borderRadius: 4,
          padding: '8px 16px',
        },
        containedPrimary: {
          backgroundColor: '#000091',
          '&:hover': {
            backgroundColor: '#6A6AF4',
          },
        },
        containedSecondary: {
          backgroundColor: '#E1000F',
          '&:hover': {
            backgroundColor: '#FF4D4D',
          },
        },
        outlinedPrimary: {
          borderColor: '#000091',
          color: '#000091',
          '&:hover': {
            borderColor: '#6A6AF4',
            backgroundColor: 'rgba(0, 0, 145, 0.04)',
          },
        },
        outlinedSecondary: {
          borderColor: '#E1000F',
          color: '#E1000F',
          '&:hover': {
            borderColor: '#FF4D4D',
            backgroundColor: 'rgba(225, 0, 15, 0.04)',
          },
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          borderRadius: 8,
          boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)',
        },
      },
    },
    MuiAppBar: {
      styleOverrides: {
        root: {
          backgroundColor: '#000091',
        },
      },
    },
  },
});

const queryClient = new QueryClient();

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider theme={theme}>
        <CssBaseline />
        <Router>
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            <Route path="/profile" element={<Profile />} />
          </Routes>
        </Router>
      </ThemeProvider>
    </QueryClientProvider>
  );
}

export default App;
