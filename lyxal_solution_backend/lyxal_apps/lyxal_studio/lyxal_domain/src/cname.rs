use sha2::{Sha256, Digest};

pub fn generate_cname(user_id: &str) -> String {
    let vowels = ['a', 'e', 'i', 'o', 'u'];
    let consonants = [
        'b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x', 'y', 'z',
    ];

    let mut hasher = Sha256::new();
    hasher.update(user_id.as_bytes());
    let hash = hasher.finalize();

    let mut result = String::new();
    let words_length = [
        std::cmp::max(4, (hash[0] % 7) as usize),
        std::cmp::max(4, (hash[0] % 7) as usize),
        std::cmp::max(4, (hash[0] % 7) as usize),
    ];

    let mut word_index = 0;
    let mut word_length_limit = words_length[word_index];
    let mut current_word_len = 0;

    for (i, &byte) in hash.iter().enumerate() {
        if i % 2 == 0 {
            result.push(consonants[(byte as usize) % consonants.len()]);
        } else {
            result.push(vowels[(byte as usize) % vowels.len()]);
        }
        
        current_word_len += 1;

        if current_word_len >= word_length_limit {
            word_index += 1;
            if word_index >= words_length.len() {
                break;
            }
            result.push('-');
            word_length_limit = words_length[word_index];
            current_word_len = 0;
        }
    }

    result
}

