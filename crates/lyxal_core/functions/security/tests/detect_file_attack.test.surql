-- lyxal-test: assertions
-- Tests de fn::security_detect_file_attack (format : crates/lyxal_core/implementation_plan.md §5).

-- test: exécutable
RETURN fn::security_detect_file_attack("setup.EXE", "application/octet-stream") == { detected: true, category: "file_attack", score: 60, dangerous_extension: true, double_extension: false, mime_mismatch: false };

-- test: double extension
RETURN fn::security_detect_file_attack("photo.jpg.exe", "image/jpeg").score == 110;

-- test: type MIME incohérent
RETURN fn::security_detect_file_attack("photo.png", "image/jpeg").mime_mismatch;

-- test: fichier ordinaire
RETURN !fn::security_detect_file_attack("rapport.pdf", "application/pdf").detected;
