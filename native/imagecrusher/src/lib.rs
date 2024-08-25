use image::{ImageBuffer, Luma};

fn extract_base_name(input: &str) -> String {
    input
        .split('/')
        .last()
        .unwrap_or(input)
        .rsplit('_')
        .last()
        .and_then(|s| s.split('.').next())
        .map(|s| {
            let file_name = input.split('/').last().unwrap_or(input);
            file_name.trim_end_matches(s).trim_end_matches('_')
        })
        .unwrap_or(input)
        .to_string()
}

fn remove_number_and_extension(input: &str) -> String {
    input
        .rsplit_once('_')
        .map(|(name, _)| name)
        .unwrap_or(input)
        .to_string()
}

#[rustler::nif]
fn convert_to_4_color_grayscale(input_path: String) {
    // Read the image
    let img = image::open(&input_path).unwrap();

    // trim file path to only file name no extension
    let base_name = extract_base_name(&input_path);
    let file_name = remove_number_and_extension(&base_name);

    //print the filename
    println!("{}", file_name);

    //reduce the image to 64x64

    let values = [16, 24, 32, 48, 64];

    for &value in values.iter() {
        let resized = img.resize(value, value, image::imageops::FilterType::Nearest);

        // Convert to grayscale
        let grey_img = resized.to_luma8();

        // increase the image contrast
        let contrast = 1.5;
        let contrast_factor = (259.0 * (contrast + 255.0)) / (255.0 * (259.0 - contrast));
        let mut result = ImageBuffer::new(grey_img.width(), grey_img.height());
        for (x, y, pixel) in grey_img.enumerate_pixels() {
            let new = ((contrast_factor * (pixel[0] as f32 - 128.0) + 128.0) as u8).min(255);
            result.put_pixel(x, y, Luma([new]));
        }

        // Create a new image buffer for the result
        let (width, height) = grey_img.dimensions();
        let mut result = ImageBuffer::new(width, height);

        // Define the 4 grayscale levels
        let levels = [0u8, 85u8, 170u8, 255u8];

        // Process each pixel
        for (x, y, pixel) in grey_img.enumerate_pixels() {
            let intensity = pixel[0];
            let new_intensity = levels[((intensity as f32 / 64.0).floor() as usize).min(3)];
            result.put_pixel(x, y, Luma([new_intensity]));
        }

        let output_path = format!("out/{}_{}", file_name, value);
        //make filename dir if not exist
        let _ = std::fs::create_dir_all(&output_path);
        // Save the result with name format file_name_size.png
        let output_path = format!("{}/{}.png", output_path, base_name);
        result.save(&output_path);
    }
}

rustler::init!("Elixir.ImageCrusher");
