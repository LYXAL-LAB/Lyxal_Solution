import React from 'react';
import Header from '../../components/header/Header';
import Footer from '../../components/Footer';

interface HomeProps {
  onNavigate?: (path: string) => void;
}

const Home: React.FC<HomeProps> = ({ onNavigate }) => {
  return (
    <div className="min-h-screen bg-base-100">
      {/* Header Component */}
      <Header 
        companyName="LYXAL"
        showNavigation={true}
        ctaText="Sign In"
        ctaHref="/signin"
        onNavigate={onNavigate || (() => {})}
      />

      {/* Hero Section */}
      <section className="hero min-h-[70vh] bg-gradient-to-br from-primary/10 to-secondary/10">
        <div className="hero-content text-center">
          <div className="max-w-4xl">
            <h1 className="text-5xl font-bold mb-6">
              La plateforme <span className="text-primary">tout-en-un</span> pour votre entreprise
            </h1>
            <p className="text-xl mb-8 text-base-content/80">
              Gérez votre CRM, finances, analytics et bien plus avec LYXAL. 
              Une solution complète et moderne pour faire grandir votre business.
            </p>
            <div className="flex gap-4 justify-center">
              <a href="/signup" className="btn btn-primary btn-lg">
                Commencer gratuitement
              </a>
              <a href="/app" className="btn btn-outline btn-lg">
                Voir la démo
              </a>
            </div>
          </div>
        </div>
      </section>

      {/* Features Preview */}
      <section className="py-20 bg-base-100">
        <div className="container mx-auto px-4">
          <div className="text-center mb-16">
            <h2 className="text-4xl font-bold mb-4">Tout ce dont vous avez besoin</h2>
            <p className="text-xl text-base-content/70">
              Une suite complète d'outils pour gérer votre entreprise efficacement
            </p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            {/* CRM */}
            <div className="card bg-base-200 shadow-lg">
              <div className="card-body text-center">
                <div className="text-4xl mb-4">👥</div>
                <h3 className="card-title justify-center">CRM Avancé</h3>
                <p>Gérez vos clients, prospects et pipeline de vente en toute simplicité.</p>
              </div>
            </div>

            {/* Finance */}
            <div className="card bg-base-200 shadow-lg">
              <div className="card-body text-center">
                <div className="text-4xl mb-4">💰</div>
                <h3 className="card-title justify-center">Finance</h3>
                <p>Suivi comptable, factures, devis et reporting financier complet.</p>
              </div>
            </div>

            {/* Analytics */}
            <div className="card bg-base-200 shadow-lg">
              <div className="card-body text-center">
                <div className="text-4xl mb-4">📊</div>
                <h3 className="card-title justify-center">Analytics</h3>
                <p>Tableaux de bord et analyses pour prendre les bonnes décisions.</p>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-primary text-primary-content">
        <div className="container mx-auto px-4 text-center">
          <h2 className="text-4xl font-bold mb-6">
            Prêt à transformer votre entreprise ?
          </h2>
          <p className="text-xl mb-8 opacity-90">
            Rejoignez des milliers d'entreprises qui font confiance à LYXAL
          </p>
          <div className="flex gap-4 justify-center">
            <a href="/signup" className="btn btn-secondary btn-lg">
              Essai gratuit 30 jours
            </a>
            <a href="/contact" className="btn btn-outline btn-lg text-primary-content border-primary-content hover:bg-primary-content hover:text-primary">
              Parler à un expert
            </a>
          </div>
        </div>
      </section>

      {/* Footer Component */}
      <Footer 
        companyName="LYXAL Platform"
        version="v1.0.0"
        status="success"
        showDate={true}
      />
    </div>
  );
};

export default Home; 