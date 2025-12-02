import React, { useState, useEffect, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { ChevronDown } from 'lucide-react';
import { Button } from '../ui/Button';
import { cn } from '../../lib/utils';

interface Language {
    code: string;
    name: string;
    flag: string;
}

const languages: Language[] = [
    { code: 'fr', name: 'Français', flag: '🇫🇷' },
    { code: 'en', name: 'English', flag: '🇬🇧' },
    { code: 'es', name: 'Español', flag: '🇪🇸' },
    { code: 'de', name: 'Deutsch', flag: '🇩🇪' },
    { code: 'it', name: 'Italiano', flag: '🇮🇹' }
];

export const LanguageSelect: React.FC = () => {
    const { t, i18n } = useTranslation();
    const [dropdownOpen, setDropdownOpen] = useState(false);
    const dropdownRef = useRef<HTMLDivElement>(null);

    const currentLanguage = languages.find(lang => lang.code === i18n.language) || languages[0];

    const toggleDropdown = () => setDropdownOpen(!dropdownOpen);

    const selectLanguage = (langCode: string) => {
        i18n.changeLanguage(langCode);
        setDropdownOpen(false);
    };

    // Close dropdown when clicking outside
    useEffect(() => {
        const handleClickOutside = (event: MouseEvent) => {
            if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
                setDropdownOpen(false);
            }
        };

        document.addEventListener('mousedown', handleClickOutside);
        return () => {
            document.removeEventListener('mousedown', handleClickOutside);
        };
    }, []);

    return (
        <div className="relative" ref={dropdownRef}>
            <Button
                onClick={toggleDropdown}
                variant="ghost"
                size="sm"
                className="rounded-md px-3 py-2 text-sm font-medium hover:bg-accent transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2"
                aria-label={t('language.select')}
                aria-haspopup="true"
                aria-expanded={dropdownOpen}
            >
                <span className="mr-1.5 text-lg leading-none" aria-hidden="true">{currentLanguage?.flag || '🇫🇷'}</span>
                <span className="hidden sm:inline">{currentLanguage?.name || 'Français'}</span>
                <ChevronDown size={16} className="ml-1 text-muted-foreground" />
            </Button>

            {/* Dropdown menu */}
            {dropdownOpen && (
                <div
                    className="absolute right-0 mt-2 w-48 origin-top-right clay-card rounded-md shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none z-50 animate-in fade-in zoom-in-95 duration-100"
                    role="menu"
                    aria-orientation="vertical"
                    aria-label={t('language.select')}
                >
                    <div className="p-1">
                        {languages.map((lang) => (
                            <button
                                key={lang.code}
                                onClick={() => selectLanguage(lang.code)}
                                className={cn(
                                    'flex w-full items-center space-x-3 rounded-md px-3 py-2 text-sm transition-colors',
                                    i18n.language === lang.code
                                        ? 'bg-accent text-primary font-medium'
                                        : 'hover:bg-accent/50'
                                )}
                                role="menuitem"
                            >
                                <span className="text-lg leading-none" aria-hidden="true">{lang.flag}</span>
                                <span className="flex-1 text-left">{lang.name}</span>
                                {i18n.language === lang.code && (
                                    <span
                                        className="ml-auto h-1.5 w-1.5 rounded-full bg-primary"
                                        aria-label="selected"
                                    ></span>
                                )}
                            </button>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
};
