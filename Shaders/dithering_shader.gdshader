shader_type canvas_item;

// Ссылка на экран
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// --- Настройки Дизеринга ---
uniform float dither_size : hint_range(1.0, 8.0) = 2.0;
uniform float color_depth : hint_range(1.0, 16.0) = 4.0;

// --- Настройки Хроматической Аберрации (НОВОЕ) ---
// intensity управляем из скрипта. 0.0 - нет эффекта, 0.02 - сильный эффект.
uniform float chromatic_intensity : hint_range(0.0, 0.05, 0.001) = 0.0;

// Матрица Байера 4x4
const float bayer_matrix[16] = float[](
    0.0 / 16.0, 8.0 / 16.0, 2.0 / 16.0, 10.0 / 16.0,
    12.0 / 16.0, 4.0 / 16.0, 14.0 / 16.0, 6.0 / 16.0,
    3.0 / 16.0, 11.0 / 16.0, 1.0 / 16.0, 9.0 / 16.0,
    15.0 / 16.0, 7.0 / 16.0, 13.0 / 16.0, 5.0 / 16.0
);

void fragment() {
    vec2 uv = SCREEN_UV;

    // 1. --- Хроматическая Аберрация (НОВОЕ) ---
    // Вычисляем направление от центра экрана
    vec2 shift_direction = uv - vec2(0.5);

    // Сэмплируем каналы со сдвигом.
    // Красный канал сдвигаем "наружу", синий "внутрь", зеленый оставляем на месте.
    // Чем дальше от центра, тем сильнее сдвиг.
    float r = texture(screen_texture, uv + shift_direction * chromatic_intensity).r;
    float g = texture(screen_texture, uv).g;
    float b = texture(screen_texture, uv - shift_direction * chromatic_intensity).b;

    // Собираем "расслоенный" цвет
    vec3 distorted_color = vec3(r, g, b);

    // 2. --- Дизеринг (Старый код, применяется к новому цвету) ---
    // Переводим в ЧБ используя уже искаженный цвет
    float gray = (distorted_color.r + distorted_color.g + distorted_color.b) / 3.0;

    int x = int(FRAGCOORD.x / dither_size) % 4;
    int y = int(FRAGCOORD.y / dither_size) % 4;
    float bayer_value = bayer_matrix[x + y * 4];

    // Квантование и применение матрицы
    float final_r = floor(distorted_color.r * color_depth + bayer_value) / color_depth;
    float final_g = floor(distorted_color.g * color_depth + bayer_value) / color_depth;
    float final_b = floor(distorted_color.b * color_depth + bayer_value) / color_depth;

    // Выводим результат
    COLOR = vec4(final_r, final_g, final_b, 1.0);
}