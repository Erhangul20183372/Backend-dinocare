export const randomAccessibleColor = (threshold: number = 4.5): string => {
  const toHex = (n: number): string => n.toString(16).padStart(2, "0");

  const srgbToLin = (v: number): number => {
    v /= 255;
    return v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
  };

  const relLum = ([r, g, b]: [number, number, number]): number =>
    0.2126 * srgbToLin(r) + 0.7152 * srgbToLin(g) + 0.0722 * srgbToLin(b);

  const contrast = (rgb: [number, number, number], againstWhite: boolean): number => {
    const L1 = againstWhite ? 1 : relLum(rgb);
    const L2 = againstWhite ? relLum(rgb) : 0;
    const lighter = Math.max(L1, L2);
    const darker = Math.min(L1, L2);
    return (lighter + 0.05) / (darker + 0.05);
  };

  const passesBoth = (rgb: [number, number, number]): boolean =>
    contrast(rgb, true) >= threshold && contrast(rgb, false) >= threshold;

  const rnd = (): number => Math.floor(Math.random() * 176) + 40;

  for (let i = 0; i < 5000; i++) {
    const rgb: [number, number, number] = [rnd(), rnd(), rnd()];
    if (passesBoth(rgb)) {
      return `#${toHex(rgb[0])}${toHex(rgb[1])}${toHex(rgb[2])}`;
    }
  }

  // Fallback: neutral mid-gray (~0.179 luminance) always passes
  return "#757575";
};

export const bestTextOn = (bgHex: string): "#FFFFFF" | "#000000" => {
  const rgb: [number, number, number] = [
    parseInt(bgHex.slice(1, 3), 16),
    parseInt(bgHex.slice(3, 5), 16),
    parseInt(bgHex.slice(5, 7), 16),
  ];

  const srgbToLin = (v: number): number => {
    v /= 255;
    return v <= 0.04045 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
  };

  const lum = 0.2126 * srgbToLin(rgb[0]) + 0.7152 * srgbToLin(rgb[1]) + 0.0722 * srgbToLin(rgb[2]);
  const contrastWhite = (1 + 0.05) / (lum + 0.05);
  const contrastBlack = (lum + 0.05) / 0.05;

  return contrastWhite >= contrastBlack ? "#FFFFFF" : "#000000";
};
