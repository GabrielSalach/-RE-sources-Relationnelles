import React from 'react';
import { Container, Typography, Box, Paper, Avatar, Button } from '@mui/material';
import { useNavigate } from 'react-router-dom';

function Profile() {
  const navigate = useNavigate();

  // TODO: Récupérer les données de l'utilisateur depuis Supabase
  const user = {
    firstName: 'John',
    lastName: 'Doe',
    email: 'john.doe@example.com',
    avatar: null
  };

  const handleLogout = () => {
    // TODO: Implémenter la déconnexion avec Supabase
    navigate('/login');
  };

  return (
    <Container maxWidth="md">
      <Box sx={{ mt: 4 }}>
        <Paper elevation={3} sx={{ p: 4 }}>
          <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
            <Avatar
              sx={{ width: 100, height: 100, mb: 2 }}
              src={user.avatar}
            >
              {user.firstName[0]}{user.lastName[0]}
            </Avatar>

            <Typography variant="h4" component="h1" gutterBottom>
              {user.firstName} {user.lastName}
            </Typography>

            <Typography variant="body1" color="text.secondary" gutterBottom>
              {user.email}
            </Typography>

            <Button
              variant="outlined"
              color="error"
              onClick={handleLogout}
              sx={{ mt: 2 }}
            >
              Se déconnecter
            </Button>
          </Box>
        </Paper>
      </Box>
    </Container>
  );
}

export default Profile; 