import * as React from "react"
import { cn } from "../lib/utils"

interface AppLogoProps {
    size?: 'sm' | 'md' | 'lg'
    showText?: boolean
    showVersion?: boolean
    textClass?: string
    className?: string
}

export const AppLogo: React.FC<AppLogoProps> = ({
    size = 'md',
    showText = true,
    showVersion = false,
    textClass = '',
    className
}) => {
    const appVersion = (window as any).ACKIFY_VERSION || ''

    const sizeClasses = {
        sm: { icon: 'h-5 w-5', text: 'text-base' },
        md: { icon: 'h-8 w-8', text: 'text-xl' },
        lg: { icon: 'h-10 w-10', text: 'text-2xl' }
    }

    const classes = sizeClasses[size]

    return (
        <div className={cn("flex items-center space-x-2", className)}>
            <svg
                className={cn(classes.icon, 'text-primary')}
                viewBox="0 0 24 24"
                fill="none"
                xmlns="http://www.w3.org/2000/svg"
            >
                <path
                    d="M9 12L11 14L15 10M21 12C21 16.9706 16.9706 21 12 21C7.02944 21 3 16.9706 3 12C3 7.02944 7.02944 3 12 3C16.9706 3 21 7.02944 21 12Z"
                    stroke="currentColor"
                    strokeWidth="2"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                />
            </svg>
            {showText && (
                <div className="flex flex-col">
                    <span className={cn(classes.text, textClass || 'font-bold text-foreground')}>
                        Ackify
                    </span>
                    {showVersion && appVersion && (
                        <span className="text-xs text-muted-foreground leading-none -mt-0.5">
                            {appVersion}
                        </span>
                    )}
                </div>
            )}
        </div>
    )
}
