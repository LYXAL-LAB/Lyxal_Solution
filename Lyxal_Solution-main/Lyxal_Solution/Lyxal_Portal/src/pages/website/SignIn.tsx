import React from 'react';
import { LoginPage } from '@lyxalkitui';

const TestLyxalKitUI: React.FC = () => {
  const handleSubmit = async (data: { email: string; password: string; rememberMe: boolean }) => {
    console.log('Données de connexion:', data);
    alert(`Connexion avec: ${data.email}`);
  };

  const handleNavigateHome = () => {
    console.log('Navigation vers accueil');
    alert('Retour à l\'accueil');
  };

  const handleForgotPassword = () => {
    console.log('Mot de passe oublié');
    alert('Fonctionnalité mot de passe oublié');
  };

  const handleGoogleLogin = () => {
    console.log('Connexion Google');
    alert('Connexion avec Google');
  };

  const handleGitHubLogin = () => {
    console.log('Connexion GitHub');
    alert('Connexion avec GitHub');
  };

  return (
    <LoginPage
      title="LYXAL TEST"
      subtitle="Test du composant LoginPage de LyxalKitUI"
      onSubmit={handleSubmit}
      onNavigateHome={handleNavigateHome}
      onForgotPassword={handleForgotPassword}
      onGoogleLogin={handleGoogleLogin}
      onGitHubLogin={handleGitHubLogin}
      footerText="@LYXAL KitUI Test - 2025"
    />
  );
};

export default TestLyxalKitUI; 