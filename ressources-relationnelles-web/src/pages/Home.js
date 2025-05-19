import React from 'react';
import { Container, Typography, Box, Grid, Card, CardContent, Button, Paper, Link } from '@mui/material';
import { useNavigate } from 'react-router-dom';
import { styled } from '@mui/material/styles';

const Header = styled(Box)(({ theme }) => ({
  backgroundColor: theme.palette.primary.main,
  color: theme.palette.common.white,
  padding: theme.spacing(2, 0),
  borderBottom: '1px solid rgba(255, 255, 255, 0.1)',
}));

const HeroSection = styled(Box)(({ theme }) => ({
  backgroundColor: theme.palette.primary.main,
  color: theme.palette.common.white,
  padding: theme.spacing(6, 0),
  position: 'relative',
  '&::after': {
    content: '""',
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    height: '4px',
    background: 'linear-gradient(90deg, #000091 0%, #E1000F 100%)',
  },
}));

const Logo = styled('img')({
  height: '60px',
  marginRight: '16px',
});

const CategoryCard = styled(Card)(({ theme, color }) => ({
  height: '100%',
  display: 'flex',
  flexDirection: 'column',
  border: 'none',
  boxShadow: '0 1px 3px rgba(0, 0, 0, 0.1)',
  transition: 'all 0.2s ease-in-out',
  '&:hover': {
    transform: 'translateY(-4px)',
    boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)',
  },
}));

const Footer = styled(Box)(({ theme }) => ({
  backgroundColor: theme.palette.grey[900],
  color: theme.palette.common.white,
  padding: theme.spacing(4, 0),
  marginTop: theme.spacing(6),
}));

function Home() {
  const navigate = useNavigate();

  const categories = [
    { title: 'Famille', icon: '👨‍👩‍👧‍👦', color: '#000091', description: 'Ressources pour la vie familiale' },
    { title: 'Amis', icon: '👥', color: '#E1000F', description: 'Développer ses relations amicales' },
    { title: 'Couple', icon: '❤️', color: '#009099', description: 'Renforcer les liens du couple' },
    { title: 'Travail', icon: '💼', color: '#6A6AF4', description: 'Améliorer les relations professionnelles' },
  ];

  return (
    <Box>
      <Header>
        <Container maxWidth="lg">
          <Box sx={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
            <Box sx={{ display: 'flex', alignItems: 'center' }}>
              <Logo src="/assets/logo-ministere.png" alt="Logo Ministère" />
              <Typography variant="h6" sx={{ color: 'white', fontWeight: 500 }}>
                Ministère des Solidarités et de la Santé
              </Typography>
            </Box>
            <Box>
              <Button 
                variant="outlined" 
                color="inherit"
                onClick={() => navigate('/login')}
                sx={{ mr: 2 }}
              >
                Se connecter
              </Button>
              <Button 
                variant="contained" 
                color="secondary"
                onClick={() => navigate('/register')}
              >
                S'inscrire
              </Button>
            </Box>
          </Box>
        </Container>
      </Header>

      <HeroSection>
        <Container maxWidth="lg">
          <Grid container spacing={4} alignItems="center">
            <Grid item xs={12} md={6}>
              <Typography variant="h2" component="h1" gutterBottom sx={{ color: 'white', fontWeight: 700 }}>
                (RE) Sources Relationnelles
              </Typography>
              <Typography variant="h5" paragraph sx={{ color: 'white', mb: 4 }}>
                Une plateforme dédiée au développement des compétences relationnelles
              </Typography>
              <Button 
                variant="contained" 
                color="secondary"
                size="large"
                onClick={() => navigate('/register')}
                sx={{ mr: 2 }}
              >
                Découvrir la plateforme
              </Button>
              <Button 
                variant="outlined" 
                color="inherit"
                size="large"
                onClick={() => navigate('/login')}
              >
                Se connecter
              </Button>
            </Grid>
            <Grid item xs={12} md={6}>
              <Box sx={{ 
                backgroundColor: 'rgba(255, 255, 255, 0.1)', 
                borderRadius: 2,
                p: 3,
                color: 'white'
              }}>
                <Typography variant="h6" gutterBottom sx={{ color: 'white', fontWeight: 500 }}>
                  Une initiative du Ministère des Solidarités et de la Santé
                </Typography>
                <Typography variant="body1" paragraph sx={{ color: 'white' }}>
                  Développez vos compétences relationnelles grâce à nos ressources pédagogiques et nos outils d'accompagnement.
                </Typography>
                <Typography variant="body1" sx={{ color: 'white' }}>
                  Accédez à des contenus adaptés à vos besoins et suivez votre progression.
                </Typography>
              </Box>
            </Grid>
          </Grid>
        </Container>
      </HeroSection>

      <Container maxWidth="lg" sx={{ py: 6 }}>
        <Typography variant="h4" component="h2" gutterBottom align="center" sx={{ mb: 4 }}>
          Découvrez nos ressources par catégorie
        </Typography>
        <Grid container spacing={4}>
          {categories.map((category) => (
            <Grid item xs={12} sm={6} md={3} key={category.title}>
              <CategoryCard>
                <CardContent>
                  <Box sx={{ 
                    backgroundColor: `${category.color}15`,
                    borderRadius: 2,
                    p: 2,
                    mb: 2,
                    display: 'flex',
                    justifyContent: 'center'
                  }}>
                    <Typography variant="h1" sx={{ fontSize: '3rem' }}>
                      {category.icon}
                    </Typography>
                  </Box>
                  <Typography variant="h6" gutterBottom sx={{ color: category.color }}>
                    {category.title}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {category.description}
                  </Typography>
                </CardContent>
              </CategoryCard>
            </Grid>
          ))}
        </Grid>
      </Container>

      <Footer>
        <Container maxWidth="lg">
          <Grid container spacing={4}>
            <Grid item xs={12} md={4}>
              <Typography variant="h6" gutterBottom sx={{ color: 'white' }}>
                À propos
              </Typography>
              <Typography variant="body2" paragraph sx={{ color: 'white' }}>
                (RE) Sources Relationnelles est une plateforme du Ministère des Solidarités et de la Santé
                dédiée au développement des compétences relationnelles.
              </Typography>
            </Grid>
            <Grid item xs={12} md={4}>
              <Typography variant="h6" gutterBottom sx={{ color: 'white' }}>
                Liens utiles
              </Typography>
              <Box component="ul" sx={{ listStyle: 'none', p: 0, m: 0 }}>
                <Box component="li" sx={{ mb: 1 }}>
                  <Link href="#" color="inherit" underline="hover" sx={{ color: 'white' }}>Mentions légales</Link>
                </Box>
                <Box component="li" sx={{ mb: 1 }}>
                  <Link href="#" color="inherit" underline="hover" sx={{ color: 'white' }}>Politique de confidentialité</Link>
                </Box>
                <Box component="li" sx={{ mb: 1 }}>
                  <Link href="#" color="inherit" underline="hover" sx={{ color: 'white' }}>Accessibilité</Link>
                </Box>
              </Box>
            </Grid>
            <Grid item xs={12} md={4}>
              <Typography variant="h6" gutterBottom sx={{ color: 'white' }}>
                Contact
              </Typography>
              <Typography variant="body2" paragraph sx={{ color: 'white' }}>
                Pour toute question, contactez-nous à :
                <br />
                <Link href="mailto:contact@ressources-relationnelles.fr" color="inherit" underline="hover" sx={{ color: 'white' }}>
                  contact@ressources-relationnelles.fr
                </Link>
              </Typography>
            </Grid>
          </Grid>
        </Container>
      </Footer>
    </Box>
  );
}

export default Home; 