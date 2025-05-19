import React, { useState } from 'react';
import { 
  Container, 
  Box, 
  Typography, 
  TextField, 
  Button, 
  Paper,
  Link
} from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { styled } from '@mui/material/styles';

const Logo = styled('img')({
  height: '60px',
  marginBottom: '20px',
});

const FormContainer = styled(Paper)(({ theme }) => ({
  padding: theme.spacing(4),
  display: 'flex',
  flexDirection: 'column',
  alignItems: 'center',
  maxWidth: '400px',
  margin: '0 auto',
  marginTop: theme.spacing(4),
  borderRadius: theme.spacing(1),
  boxShadow: '0 2px 4px rgba(0, 0, 0, 0.1)',
}));

function Login() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    email: '',
    password: '',
  });

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    // TODO: Implémenter la logique de connexion
    console.log('Tentative de connexion avec:', formData);
  };

  return (
    <Container maxWidth="sm">
      <Box sx={{ 
        display: 'flex', 
        flexDirection: 'column', 
        alignItems: 'center',
        mt: 4
      }}>
        <FormContainer>
          <Box sx={{ width: '100%', display: 'flex', justifyContent: 'flex-start', mb: 2 }}>
            <Link 
              component="button"
              variant="body2"
              onClick={() => navigate('/')}
              sx={{ color: 'primary.main', textDecoration: 'none' }}
            >
              ← Retour à l'accueil
            </Link>
          </Box>
          <Logo 
            src="/assets/logo-ministere.png" 
            alt="Logo Ministère des Solidarités et de la Santé"
          />
          <Typography variant="h5" component="h1" gutterBottom align="center" sx={{ color: 'primary.main' }}>
            Connexion
          </Typography>
          <form onSubmit={handleSubmit} style={{ width: '100%' }}>
            <TextField
              margin="normal"
              required
              fullWidth
              id="email"
              label="Adresse email"
              name="email"
              autoComplete="email"
              autoFocus
              value={formData.email}
              onChange={handleChange}
            />
            <TextField
              margin="normal"
              required
              fullWidth
              name="password"
              label="Mot de passe"
              type="password"
              id="password"
              autoComplete="current-password"
              value={formData.password}
              onChange={handleChange}
            />
            <Button
              type="submit"
              fullWidth
              variant="contained"
              color="primary"
              sx={{ mt: 3, mb: 2 }}
            >
              Se connecter
            </Button>
            <Box sx={{ textAlign: 'center' }}>
              <Link 
                component="button"
                variant="body2"
                onClick={() => navigate('/register')}
                sx={{ color: 'primary.main' }}
              >
                Pas encore de compte ? S'inscrire
              </Link>
            </Box>
          </form>
        </FormContainer>
      </Box>
    </Container>
  );
}

export default Login; 