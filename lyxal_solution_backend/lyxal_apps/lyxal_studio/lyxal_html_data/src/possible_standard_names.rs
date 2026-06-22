use std::collections::HashMap;
use lazy_static::lazy_static;

lazy_static! {
    pub static ref POSSIBLE_STANDARD_NAMES: HashMap<&'static str, &'static str> = {
        let mut m = HashMap::new();
        m.insert("accept-charset", "acceptCharset");
        m.insert("accesskey", "accessKey");
        m.insert("allowfullscreen", "allowFullScreen");
        m.insert("autocapitalize", "autoCapitalize");
        m.insert("autocomplete", "autoComplete");
        m.insert("autocorrect", "autoCorrect");
        m.insert("autofocus", "autoFocus");
        m.insert("autoplay", "autoPlay");
        m.insert("cellpadding", "cellPadding");
        m.insert("cellspacing", "cellSpacing");
        m.insert("charset", "charSet");
        m.insert("class", "className");
        m.insert("classid", "classId");
        m.insert("colspan", "colSpan");
        m.insert("contenteditable", "contentEditable");
        m.insert("contextmenu", "contextMenu");
        m.insert("controlslist", "controlsList");
        m.insert("crossorigin", "crossOrigin");
        m.insert("datetime", "dateTime");
        m.insert("enctype", "encType");
        m.insert("formaction", "formAction");
        m.insert("formenctype", "formEncType");
        m.insert("formmethod", "formMethod");
        m.insert("formnovalidate", "formNoValidate");
        m.insert("formtarget", "formTarget");
        m.insert("frameborder", "frameBorder");
        m.insert("hreflang", "hrefLang");
        m.insert("http-equiv", "httpEquiv");
        m.insert("inputmode", "inputMode");
        m.insert("keytype", "keyType");
        m.insert("marginheight", "marginHeight");
        m.insert("marginwidth", "marginWidth");
        m.insert("maxlength", "maxLength");
        m.insert("minlength", "minLength");
        m.insert("novalidate", "noValidate");
        m.insert("readonly", "readOnly");
        m.insert("rowspan", "rowSpan");
        m.insert("spellcheck", "spellCheck");
        m.insert("srcdoc", "srcDoc");
        m.insert("srclang", "srcLang");
        m.insert("srcset", "srcSet");
        m.insert("tabindex", "tabIndex");
        m.insert("usemap", "useMap");
        // ... (Le mapping continue pour SVG et ARIA)
        m
    };
}
