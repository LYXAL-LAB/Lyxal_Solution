import * as React from "react"
import { Link, useLocation, useNavigate } from "react-router-dom"
import { useTranslation } from "react-i18next"
import { useAuthStore } from "../../store/auth.store"
import { Button } from "../ui/Button"
import { AppLogo } from "../AppLogo"
import { Menu, X, ChevronDown, User, LogOut, Shield, FileSignature } from "lucide-react"
import { cn } from "../../lib/utils"
import { SkipToContent } from "../accessibility/SkipToContent"
import { LanguageSelect } from "./LanguageSelect"
import { ThemeToggle } from "./ThemeToggle"

export const Layout: React.FC<{ children: React.ReactNode }> = ({ children }) => {
    const { t } = useTranslation()
    const location = useLocation()
    const navigate = useNavigate()
    const { isAuthenticated, isAdmin, user, logout } = useAuthStore()

    const [mobileMenuOpen, setMobileMenuOpen] = React.useState(false)
    const [userMenuOpen, setUserMenuOpen] = React.useState(false)

    const isActive = (path: string) => location.pathname === path

    const handleLogin = () => {
        navigate('/auth')
    }

    const handleLogout = async () => {
        await logout()
        setUserMenuOpen(false)
    }

    return (
        <div className="flex min-h-screen flex-col bg-background relative">
            <SkipToContent />
            {/* Header */}
            <header className="sticky top-0 z-50 w-full border-b border-border/40 clay-card backdrop-blur supports-[backdrop-filter]:bg-background/60">
                <nav className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8" aria-label={t('nav.mainNavigation')}>
                    <div className="flex h-16 items-center justify-between">
                        {/* Logo */}
                        <div className="flex items-center">
                            <Link to="/" className="focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 rounded-md">
                                <AppLogo size="md" showVersion={true} />
                            </Link>
                        </div>

                        {/* Desktop Navigation */}
                        {isAuthenticated && (
                            <div className="hidden md:flex md:items-center md:space-x-6">
                                <Link
                                    to="/"
                                    className={cn(
                                        "text-sm font-medium transition-colors hover:text-primary",
                                        isActive('/') ? 'text-primary' : 'text-muted-foreground'
                                    )}
                                >
                                    {t('nav.home')}
                                </Link>

                                <Link
                                    to="/signatures"
                                    className={cn(
                                        "text-sm font-medium transition-colors hover:text-primary",
                                        isActive('/signatures') ? 'text-primary' : 'text-muted-foreground'
                                    )}
                                >
                                    {t('nav.myConfirmations')}
                                </Link>

                                {isAdmin && (
                                    <Link
                                        to="/admin"
                                        className={cn(
                                            "text-sm font-medium transition-colors hover:text-primary",
                                            isActive('/admin') ? 'text-primary' : 'text-muted-foreground'
                                        )}
                                    >
                                        {t('nav.admin')}
                                    </Link>
                                )}
                            </div>
                        )}

                        {/* Right side: Auth & Settings */}
                        <div className="flex items-center space-x-2">
                            {/* Desktop Settings */}
                            <div className="hidden md:flex items-center space-x-2 mr-2">
                                <ThemeToggle />
                                <LanguageSelect />
                            </div>

                            {/* Desktop Auth */}
                            {isAuthenticated ? (
                                <div className="hidden md:block relative">
                                    <button
                                        onClick={() => setUserMenuOpen(!userMenuOpen)}
                                        className="flex items-center space-x-2 rounded-md px-3 py-2 text-sm font-medium hover:bg-accent transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                                        aria-haspopup="true"
                                        aria-expanded={userMenuOpen}
                                    >
                                        <User size={18} />
                                        <span className="text-foreground">{user?.email?.split('@')[0]}</span>
                                        <ChevronDown size={16} className="text-muted-foreground" />
                                    </button>

                                    {/* User dropdown */}
                                    {userMenuOpen && (
                                        <div
                                            className="absolute right-0 mt-2 w-56 origin-top-right clay-card rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
                                            role="menu"
                                            aria-orientation="vertical"
                                        >
                                            <div className="p-2">
                                                <div className="px-3 py-2 text-sm text-muted-foreground border-b border-border/40 mb-2">
                                                    <p className="font-medium text-foreground">{user?.name}</p>
                                                    <p className="text-xs truncate">{user?.email}</p>
                                                </div>

                                                <Link
                                                    to="/signatures"
                                                    onClick={() => setUserMenuOpen(false)}
                                                    className="flex items-center space-x-2 rounded-md px-3 py-2 text-sm hover:bg-accent transition-colors"
                                                    role="menuitem"
                                                >
                                                    <FileSignature size={16} />
                                                    <span>{t('nav.myConfirmations')}</span>
                                                </Link>

                                                {isAdmin && (
                                                    <Link
                                                        to="/admin"
                                                        onClick={() => setUserMenuOpen(false)}
                                                        className="flex items-center space-x-2 rounded-md px-3 py-2 text-sm hover:bg-accent transition-colors"
                                                        role="menuitem"
                                                    >
                                                        <Shield size={16} />
                                                        <span>{t('nav.administration')}</span>
                                                    </Link>
                                                )}

                                                <div className="border-t border-border/40 my-2"></div>

                                                <button
                                                    onClick={handleLogout}
                                                    className="flex w-full items-center space-x-2 rounded-md px-3 py-2 text-sm text-destructive hover:bg-destructive/10 transition-colors"
                                                    role="menuitem"
                                                >
                                                    <LogOut size={16} />
                                                    <span>{t('nav.logout')}</span>
                                                </button>
                                            </div>
                                        </div>
                                    )}
                                </div>
                            ) : (
                                <Button onClick={handleLogin} variant="default" size="sm" className="hidden md:inline-flex">
                                    {t('nav.login')}
                                </Button>
                            )}

                            {/* Mobile menu button */}
                            <button
                                onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
                                className="md:hidden rounded-md p-2 hover:bg-accent transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                                aria-label={t('nav.mobileMenu')}
                                aria-expanded={mobileMenuOpen}
                            >
                                {mobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
                            </button>
                        </div>
                    </div>
                </nav>

                {/* Mobile menu */}
                {mobileMenuOpen && (
                    <div className="md:hidden border-t border-border/40">
                        <div className="space-y-1 px-4 pb-3 pt-2">
                            {isAuthenticated ? (
                                <>
                                    <Link
                                        to="/"
                                        onClick={() => setMobileMenuOpen(false)}
                                        className={cn(
                                            "block rounded-md px-3 py-2 text-base font-medium transition-colors",
                                            isActive('/') ? 'bg-accent text-primary' : 'hover:bg-accent'
                                        )}
                                    >
                                        {t('nav.home')}
                                    </Link>

                                    <Link
                                        to="/signatures"
                                        onClick={() => setMobileMenuOpen(false)}
                                        className={cn(
                                            "block rounded-md px-3 py-2 text-base font-medium transition-colors",
                                            isActive('/signatures') ? 'bg-accent text-primary' : 'hover:bg-accent'
                                        )}
                                    >
                                        {t('nav.myConfirmations')}
                                    </Link>

                                    {isAdmin && (
                                        <Link
                                            to="/admin"
                                            onClick={() => setMobileMenuOpen(false)}
                                            className={cn(
                                                "block rounded-md px-3 py-2 text-base font-medium transition-colors",
                                                isActive('/admin') ? 'bg-accent text-primary' : 'hover:bg-accent'
                                            )}
                                        >
                                            {t('nav.administration')}
                                        </Link>
                                    )}

                                    <div className="border-t border-border/40 pt-3 mt-3">
                                        <div className="px-3 py-2 text-sm text-muted-foreground mb-2">
                                            <p className="font-medium text-foreground">{user?.name}</p>
                                            <p className="text-xs">{user?.email}</p>
                                        </div>
                                        <button
                                            onClick={handleLogout}
                                            className="w-full text-left rounded-md px-3 py-2 text-base font-medium text-destructive hover:bg-destructive/10 transition-colors"
                                        >
                                            {t('nav.logout')}
                                        </button>
                                    </div>
                                </>
                            ) : (
                                <div className="space-y-3">
                                    <Button onClick={handleLogin} variant="default" className="w-full">
                                        {t('nav.login')}
                                    </Button>
                                </div>
                            )}

                            {/* Mobile Settings */}
                            <div className="border-t border-border/40 pt-3 mt-3 flex items-center justify-between px-2">
                                <span className="text-sm font-medium text-muted-foreground">{t('settings.theme')}</span>
                                <div className="flex items-center space-x-2">
                                    <ThemeToggle />
                                    <LanguageSelect />
                                </div>
                            </div>
                        </div>
                    </div>
                )}
            </header>

            {/* Main Content - Children render directly */}
            <main id="main-content" className="flex-grow w-full">
                {children}
            </main>

            {/* Footer */}
            <footer className="flex-shrink-0 border-t border-border/40 mt-auto">
                <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-8">
                    <div className="flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
                        <div className="flex items-center space-x-2">
                            <AppLogo size="sm" showText={true} />
                        </div>
                        <div className="text-sm text-muted-foreground">
                            <p>{t('footer.copyright', { year: new Date().getFullYear() })}</p>
                        </div>
                        <div className="flex items-center space-x-4 text-sm">
                            <a href="#" className="text-muted-foreground hover:text-primary transition-colors">
                                {t('footer.privacy')}
                            </a>
                            <a href="#" className="text-muted-foreground hover:text-primary transition-colors">
                                {t('footer.terms')}
                            </a>
                        </div>
                    </div>
                </div>
            </footer>
        </div>
    )
}
