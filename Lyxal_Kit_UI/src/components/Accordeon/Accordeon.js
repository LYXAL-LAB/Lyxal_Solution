import { jsx as _jsx, jsxs as _jsxs } from "react/jsx-runtime";
import { useRef, useState, useEffect } from "react";
import defaults from "./accordion.defaults.json";
/* ============================================================================
 * Utilitaire i18n
 * ============================================================================
 */
const t = (obj, lang) => {
    if (!obj || typeof obj !== "object")
        return "";
    return obj[lang] || obj["en"] || Object.values(obj)[0] || "";
};
/* ============================================================================
 * Sous-composant : Item individuel
 * ============================================================================
 */
const AccordionItem = ({ accordionItem, isOpen, onToggle, lang, props }) => {
    const bodyRef = useRef(null);
    const { iconClosedUrl, iconOpenUrl, iconPosition, iconAlign, iconSize, headerFontSize, headerTextColor, headerBgColor, bodyFontSize, bodyTextColor, bodyBgColor, textAlign, padding, borderColor, borderStyle, borderWidth, radius, animationDuration, animationType, expandDirection } = props;
    const iconSrc = isOpen ? iconOpenUrl || iconClosedUrl : iconClosedUrl;
    const directionStyle = expandDirection === "up"
        ? { transformOrigin: "bottom" }
        : { transformOrigin: "top" };
    const animation = animationType === "fade"
        ? {
            opacity: isOpen ? 1 : 0,
            height: isOpen ? bodyRef.current?.offsetHeight : 0
        }
        : animationType === "slide"
            ? {
                transform: isOpen
                    ? "translateY(0)"
                    : expandDirection === "up"
                        ? "translateY(100%)"
                        : "translateY(-100%)",
                height: isOpen ? bodyRef.current?.offsetHeight : 0,
                opacity: isOpen ? 1 : 0.5
            }
            : {
                height: isOpen ? bodyRef.current?.offsetHeight : 0
            };
    return (_jsxs("div", { className: "accordion-item overflow-hidden", style: {
            borderColor,
            borderStyle,
            borderWidth,
            borderRadius: radius,
            backgroundColor: headerBgColor
        }, children: [_jsxs("button", { onClick: onToggle, className: "accordion-header flex w-full items-center justify-between", style: {
                    padding,
                    textAlign,
                    color: headerTextColor,
                    fontSize: headerFontSize,
                    flexDirection: iconPosition === "left" ? "row-reverse" : "row",
                    alignItems: iconAlign,
                    transition: `all ${animationDuration}ms ease`,
                    backgroundColor: headerBgColor,
                    border: "none",
                    outline: "none",
                    width: "100%",
                    cursor: "pointer"
                }, children: [_jsx("span", { className: "flex-1", children: t(accordionItem.header_i18n, lang) }), iconSrc && (_jsx("img", { src: iconSrc, alt: "icon", className: "accordion-icon", style: {
                            width: iconSize,
                            height: iconSize,
                            transition: `transform ${animationDuration}ms ease`,
                            transform: isOpen ? "rotate(180deg)" : "rotate(0deg)"
                        } }))] }), _jsx("div", { className: "accordion-body overflow-hidden transition-all ease-in-out", style: {
                    ...animation,
                    ...directionStyle,
                    transitionDuration: `${animationDuration}ms`,
                    backgroundColor: bodyBgColor
                }, children: _jsx("div", { ref: bodyRef, className: "accordion-content", style: {
                        padding,
                        color: bodyTextColor,
                        fontSize: bodyFontSize,
                        textAlign
                    }, children: t(accordionItem.body_i18n, lang) }) })] }));
};
/* ============================================================================
 * Composant principal : ACCORDION (valeurs dynamiques)
 * ============================================================================
 */
const Accordion = ({ id, userData }) => {
    // Fusion des données : DB > defaults
    const merged = {
        ...defaults,
        ...userData,
        props: { ...defaults.props, ...(userData?.props || {}) },
        items: userData?.items || defaults.items
    };
    const { lang, props, items } = merged;
    const [openIndexes, setOpenIndexes] = useState(props.defaultOpenIndex !== null ? [props.defaultOpenIndex] : []);
    const toggleIndex = (index) => {
        if (props.allowMultiple) {
            setOpenIndexes((prev) => prev.includes(index)
                ? prev.filter((i) => i !== index)
                : [...prev, index]);
        }
        else {
            setOpenIndexes((prev) => (prev.includes(index) ? [] : [index]));
        }
    };
    useEffect(() => {
        if (id)
            console.debug(`[Accordion:${id}] rendu dynamique`);
    }, [id]);
    return (_jsx("div", { id: id, className: "accordion-container", style: {
            width: props.width,
            margin: props.margin,
            backgroundColor: props.backgroundColor,
            borderColor: props.borderColor,
            borderStyle: props.borderStyle,
            borderWidth: props.borderWidth,
            borderRadius: props.radius,
            boxShadow: props.shadow
        }, children: _jsx("div", { className: "accordion-wrapper", style: {
                display: "flex",
                flexDirection: "column",
                gap: "var(--accordion-gap, 0px)"
            }, children: items.length > 0 ? (items.map((accordionItem, index) => (_jsx(AccordionItem, { accordionItem: accordionItem, isOpen: openIndexes.includes(index), onToggle: () => toggleIndex(index), lang: lang, props: props }, `${id}-${index}`)))) : (_jsx("div", { className: "accordion-empty text-center", style: {
                    padding: props.padding,
                    color: props.bodyTextColor,
                    fontSize: props.bodyFontSize
                }, children: t(props.emptyText_i18n, lang) })) }) }));
};
export default Accordion;
