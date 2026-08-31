//! CLI Interactive Prompts & Password Masking.

use std::io::{self, BufRead, Write};

/// Interactive prompt using custom reader and writer for unit testability.
pub fn prompt_from<R: BufRead, W: Write>(
    reader: &mut R,
    writer: &mut W,
    label: &str,
) -> io::Result<String> {
    write!(writer, "{}: ", label)?;
    writer.flush()?;

    let mut input = String::new();
    reader.read_line(&mut input)?;
    Ok(input.trim().to_string())
}

/// Interactive text prompt on stdin/stdout.
pub fn prompt(label: &str) -> io::Result<String> {
    let stdin = io::stdin();
    let mut reader = stdin.lock();
    let mut stdout = io::stdout();
    prompt_from(&mut reader, &mut stdout, label)
}

/// Interactive masked password prompt returning `SecretString`.
pub fn prompt_password(label: &str) -> io::Result<lyxal_crypto::SecretString> {
    let pass = rpassword::prompt_password(format!("{}: ", label))?;
    Ok(lyxal_crypto::SecretString::from(pass))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_prompt_from() {
        let input_data = "John Doe\n";
        let mut reader = io::Cursor::new(input_data);
        let mut writer = Vec::new();

        let res = prompt_from(&mut reader, &mut writer, "Username").unwrap();
        assert_eq!(res, "John Doe");
        assert_eq!(String::from_utf8(writer).unwrap(), "Username: ");
    }
}
