/// Integration test for two-phase mmproj/LLM memory split.
///
/// Phase 1: load model WITH mmproj → encode image → ImageEmbedding → drop mmproj
/// Phase 2: load model WITHOUT mmproj → ask_with_embeddings → generate text
///
/// Run with:
///   cd /Users/intiser/Documents/nobodywho/nobodywho
///   cargo test -p nobodywho two_phase -- --nocapture
#[cfg(test)]
mod tests {
    use std::sync::Arc;

    const MODEL_PATH: &str =
        "/Users/intiser/Documents/GitHub/DocSense/DocSense/GLM-OCR.Q4_K_M.gguf";
    const MMPROJ_PATH: &str =
        "/Users/intiser/Documents/GitHub/DocSense/DocSense/GLM-OCR.mmproj-Q8_0.gguf";
    const TEST_IMAGE: &str =
        "/Users/intiser/Documents/GitHub/DocSense/DocSense/TestImages/01_invoice.png";

    /// Phase 1 only: verify that encode_image produces a non-empty embedding.
    #[test]
    fn test_encode_image_produces_embedding() {
        use crate::llm::get_model;

        println!("\n=== Phase 1: load model + mmproj, encode image ===");
        let model = get_model(MODEL_PATH, false, Some(MMPROJ_PATH), None)
            .expect("Failed to load model with mmproj");

        println!("Model loaded. Encoding image...");
        let embedding = model.encode_image(TEST_IMAGE).expect("encode_image failed");

        println!(
            "Embedding: n_tokens={}, n_embd={}, nx={}, ny={}, use_non_causal={}, use_mrope={}",
            embedding.n_tokens,
            embedding.n_embd,
            embedding.nx,
            embedding.ny,
            embedding.use_non_causal,
            embedding.use_mrope
        );

        assert!(embedding.n_tokens > 0, "n_tokens should be > 0");
        assert!(embedding.n_embd > 0, "n_embd should be > 0");
        assert_eq!(
            embedding.data.len(),
            embedding.n_tokens * embedding.n_embd,
            "data.len() should equal n_tokens * n_embd"
        );
        assert!(
            embedding.data.iter().any(|&v| v != 0.0),
            "embedding data should not be all zeros"
        );

        println!("Phase 1 PASSED — embedding has {} floats", embedding.data.len());
        // model + mmproj drop here — 462MB freed
    }

    /// Full two-phase test: encode with mmproj, then generate without mmproj.
    #[test]
    fn test_two_phase_encode_and_generate() {
        use crate::chat::ChatBuilder;
        use crate::llm::get_model;

        crate::test_utils::init_test_tracing();

        // ── Phase 1: encode (mmproj loaded) ──────────────────────────────
        println!("\n=== Phase 1: encode image with mmproj ===");
        let mmproj_model = Arc::new(
            get_model(MODEL_PATH, false, Some(MMPROJ_PATH), None)
                .expect("Failed to load model with mmproj"),
        );

        let embedding = mmproj_model
            .encode_image(TEST_IMAGE)
            .expect("encode_image failed");

        println!(
            "Encoded: n_tokens={}, n_embd={}, nx={}, ny={}",
            embedding.n_tokens, embedding.n_embd, embedding.nx, embedding.ny
        );
        drop(mmproj_model); // free ~462MB mmproj
        println!("mmproj dropped — ~462MB freed");

        // ── Phase 2: generate (no mmproj) ────────────────────────────────
        println!("\n=== Phase 2: generate text without mmproj ===");
        let gen_model = Arc::new(
            get_model(MODEL_PATH, false, None, None)
                .expect("Failed to load model without mmproj"),
        );

        let chat = ChatBuilder::new(Arc::clone(&gen_model))
            .with_context_size(4096)
            .with_system_prompt(Some(
                "You are an OCR assistant. Transcribe the text in the image exactly.".to_string(),
            ))
            .build();

        let prompt = "Please read and transcribe all text visible in this image.".to_string();
        let mut stream = chat.ask_with_embeddings(prompt, vec![embedding]);

        let mut response = String::new();
        while let Some(token) = stream.next_token() {
            print!("{}", token);
            response.push_str(&token);
        }
        println!("\n\nGenerated {} chars", response.len());

        assert!(!response.is_empty(), "Response should not be empty");
        println!("\nTwo-phase test PASSED");
    }
}
