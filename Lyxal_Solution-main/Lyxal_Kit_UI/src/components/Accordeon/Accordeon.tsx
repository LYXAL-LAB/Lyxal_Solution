import React, { useRef, useState, useEffect } from "react";
import defaults from "./accordion.defaults.json";

/* ============================================================================
 * Utilitaire i18n
 * ============================================================================
 */
const t = (obj, lang) => {
  if (!obj || typeof obj !== "object") return "";
  return obj[lang] || obj["en"] || Object.values(obj)[0] || "";
};

/* ============================================================================
 * Sous-composant : Item individuel
 * ============================================================================
 */
const AccordionItem = ({ accordionItem, isOpen, onToggle, lang, props }) => {
  const bodyRef = useRef<HTMLDivElement>(null);
  const {
    iconClosedUrl,
    iconOpenUrl,
    iconPosition,
    iconAlign,
    iconSize,
    headerFontSize,
    headerTextColor,
    headerBgColor,
    bodyFontSize,
    bodyTextColor,
    bodyBgColor,
    textAlign,
    padding,
    borderColor,
    borderStyle,
    borderWidth,
    radius,
    animationDuration,
    animationType,
    expandDirection
  } = props;

  const iconSrc = isOpen ? iconOpenUrl || iconClosedUrl : iconClosedUrl;
  const directionStyle =
    expandDirection === "up"
      ? { transformOrigin: "bottom" }
      : { transformOrigin: "top" };

  const animation =
    animationType === "fade"
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

  return (
    <div
      className="accordion-item overflow-hidden"
      style={{
        borderColor,
        borderStyle,
        borderWidth,
        borderRadius: radius,
        backgroundColor: headerBgColor
      }}
    >
      <button
        onClick={onToggle}
        className="accordion-header flex w-full items-center justify-between"
        style={{
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
        }}
      >
        <span className="flex-1">{t(accordionItem.header_i18n, lang)}</span>
        {iconSrc && (
          <img
            src={iconSrc}
            alt="icon"
            className="accordion-icon"
            style={{
              width: iconSize,
              height: iconSize,
              transition: `transform ${animationDuration}ms ease`,
              transform: isOpen ? "rotate(180deg)" : "rotate(0deg)"
            }}
          />
        )}
      </button>

      <div
        className="accordion-body overflow-hidden transition-all ease-in-out"
        style={{
          ...animation,
          ...directionStyle,
          transitionDuration: `${animationDuration}ms`,
          backgroundColor: bodyBgColor
        }}
      >
        <div
          ref={bodyRef}
          className="accordion-content"
          style={{
            padding,
            color: bodyTextColor,
            fontSize: bodyFontSize,
            textAlign
          }}
        >
          {t(accordionItem.body_i18n, lang)}
        </div>
      </div>
    </div>
  );
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
  const [openIndexes, setOpenIndexes] = useState(
    props.defaultOpenIndex !== null ? [props.defaultOpenIndex] : []
  );

  const toggleIndex = (index) => {
    if (props.allowMultiple) {
      setOpenIndexes((prev) =>
        prev.includes(index)
          ? prev.filter((i) => i !== index)
          : [...prev, index]
      );
    } else {
      setOpenIndexes((prev) => (prev.includes(index) ? [] : [index]));
    }
  };

  useEffect(() => {
    if (id) console.debug(`[Accordion:${id}] rendu dynamique`);
  }, [id]);

  return (
    <div
      id={id}
      className="accordion-container"
      style={{
        width: props.width,
        margin: props.margin,
        backgroundColor: props.backgroundColor,
        borderColor: props.borderColor,
        borderStyle: props.borderStyle,
        borderWidth: props.borderWidth,
        borderRadius: props.radius,
        boxShadow: props.shadow
      }}
    >
      <div
        className="accordion-wrapper"
        style={{
          display: "flex",
          flexDirection: "column",
          gap: "var(--accordion-gap, 0px)"
        }}
      >
        {items.length > 0 ? (
          items.map((accordionItem, index) => (
            <AccordionItem
              key={`${id}-${index}`}
              accordionItem={accordionItem}
              isOpen={openIndexes.includes(index)}
              onToggle={() => toggleIndex(index)}
              lang={lang}
              props={props}
            />
          ))
        ) : (
          <div
            className="accordion-empty text-center"
            style={{
              padding: props.padding,
              color: props.bodyTextColor,
              fontSize: props.bodyFontSize
            }}
          >
            {t(props.emptyText_i18n, lang)}
          </div>
        )}
      </div>
    </div>
  );
};

export default Accordion;
