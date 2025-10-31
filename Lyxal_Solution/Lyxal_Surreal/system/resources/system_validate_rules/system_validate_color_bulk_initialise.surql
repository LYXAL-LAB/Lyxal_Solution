-- =================================================================================================
-- |
-- | Fichier : system_validate_color_bulk_initialise.surql
-- | Module : system
-- | Description : This file initialises the `fn::system_validate_color_bulk` function,
-- | which validates an array of color strings (hex codes, CSS names, or daisyUI theme names).
-- |
-- =================================================================================================
DEFINE FUNCTION IF NOT EXISTS fn::system_validate_color_bulk_initialise(
    $parent_run_id: option<string>
) {
    -- Parameters
    LET $parent_run_id = $parent_run_id OR NONE;
    LET $log_extra_tags = ['module_system'];
    LET $run_id = rand::uuid();

    -- Initialisation Logging
    fn::system_log_create_record_system(
        array::union(['log_initialisation', 'log_function', 'log_create', 'log_start'], $log_extra_tags),
        'Start: initialisation de la fonction `fn::system_validate_color_bulk`',
        { run_id: $run_id, parent_run_id: $parent_run_id }
    );
    
    -- Define the main function
    DEFINE FUNCTION IF NOT EXISTS fn::system_validate_color_bulk(
        $colors: array<string>
    ) {
        -- List of valid daisyUI color names
        LET $daisyui_colors = [
            'primary', 'secondary', 'accent', 'neutral',
            'info', 'success', 'warning', 'error'
        ];

        -- List of valid CSS color names
        LET $css_colors = [
            'aliceblue', 'antiquewhite', 'aqua', 'aquamarine', 'azure', 'beige', 'bisque', 'black', 
            'blanchedalmond', 'blue', 'blueviolet', 'brown', 'burlywood', 'cadetblue', 'chartreuse', 
            'chocolate', 'coral', 'cornflowerblue', 'cornsilk', 'crimson', 'cyan', 'darkblue', 
            'darkcyan', 'darkgoldenrod', 'darkgray', 'darkgreen', 'darkkhaki', 'darkmagenta', 
            'darkolivegreen', 'darkorange', 'darkorchid', 'darkred', 'darksalmon', 'darkseagreen', 
            'darkslateblue', 'darkslategray', 'darkturquoise', 'darkviolet', 'deeppink', 'deepskyblue', 
            'dimgray', 'dodgerblue', 'firebrick', 'floralwhite', 'forestgreen', 'fuchsia', 'gainsboro', 
            'ghostwhite', 'gold', 'goldenrod', 'gray', 'green', 'greenyellow', 'honeydew', 'hotpink', 
            'indianred', 'indigo', 'ivory', 'khaki', 'lavender', 'lavenderblush', 'lawngreen', 
            'lemonchiffon', 'lightblue', 'lightcoral', 'lightcyan', 'lightgoldenrodyellow', 'lightgray', 
            'lightgreen', 'lightpink', 'lightsalmon', 'lightseagreen', 'lightskyblue', 'lightslategray', 
            'lightsteelblue', 'lightyellow', 'lime', 'limegreen', 'linen', 'magenta', 'maroon', 
            'mediumaquamarine', 'mediumblue', 'mediumorchid', 'mediumpurple', 'mediumseagreen', 
            'mediumslateblue', 'mediumspringgreen', 'mediumturquoise', 'mediumvioletred', 'midnightblue', 
            'mintcream', 'mistyrose', 'moccasin', 'navajowhite', 'navy', 'oldlace', 'olive', 'olivedrab', 
            'orange', 'orangered', 'orchid', 'palegoldenrod', 'palegreen', 'paleturquoise', 'palevioletred', 
            'papayawhip', 'peachpuff', 'peru', 'pink', 'plum', 'powderblue', 'purple', 'red', 'rosybrown', 
            'royalblue', 'saddlebrown', 'salmon', 'sandybrown', 'seagreen', 'seashell', 'sienna', 'silver', 
            'skyblue', 'slateblue', 'slategray', 'snow', 'springgreen', 'steelblue', 'tan', 'teal', 'thistle', 
            'tomato', 'turquoise', 'violet', 'wheat', 'white', 'whitesmokeyellow', 'yellowgreen'
        ];

        -- Process each color
        LET $results = array::map($colors, |$color| {
            LET $c = string::trim(string::lowercase($color));

            -- Check for valid daisyUI color name
            IF $c IN $daisyui_colors {
                RETURN { original: $c, success: true, type: 'daisyui' };
            };

            -- Check for valid HEX color
            IF string::starts_with($c, '#') AND string::len($c) IN [4, 5, 7, 9] {
                LET $hex_part = string::slice($c, 1);
                IF string::is::hexadecimal($hex_part) {
                    RETURN { original: $c, success: true, type: 'hex' };
                };
            };

            -- Check for valid CSS color name
            IF $c IN $css_colors {
                RETURN { original: $c, success: true, type: 'css' };
            };

            -- If none, it's invalid
            RETURN { original: $c, success: false, error: "La couleur doit être un nom de thème daisyUI, un code hexadécimal ou un nom CSS valide." };
        });

        -- Separate valid and invalid results
        LET $valids = array::filter($results, |$r| $r.success == true);
        LET $errors = array::filter($results, |$r| $r.success == false);

        RETURN {
            success: array::len($errors) == 0,
            results: $results,
            valids: $valids,
            errors: $errors
        };
    }
    COMMENT 'Validates an array of colors: daisyUI theme name, hex code (#FFF/#FFFFFF) or valid CSS name. Returns detected type (daisyui/hex/css), successes and errors.'
    PERMISSIONS FULL;

    -- Finalisation Logging
    fn::system_log_create_record_system(
        array::union(['log_initialisation', 'log_function', 'log_create', 'log_done', 'log_success'], $log_extra_tags),
        'Done: initialisation de la fonction `fn::system_validate_color_bulk`',
        { run_id: $run_id, parent_run_id: $parent_run_id }
    );

    RETURN {
        run_id: $run_id,
        parent_run_id: $parent_run_id,
        success: true
    };
}
COMMENT "Initialises the color validation function."
PERMISSIONS FULL;
