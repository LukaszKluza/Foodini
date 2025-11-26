import cv2
import numpy as np

A_CODE = {
    "0001101": "0",
    "0011001": "1",
    "0010011": "2",
    "0111101": "3",
    "0100011": "4",
    "0110001": "5",
    "0101111": "6",
    "0111011": "7",
    "0110111": "8",
    "0001011": "9",
}

B_CODE = {
    "0100111": "0",
    "0110011": "1",
    "0011011": "2",
    "0100001": "3",
    "0011101": "4",
    "0111001": "5",
    "0000101": "6",
    "0010001": "7",
    "0001001": "8",
    "0010111": "9",
}

C_CODE = {
    "1110010": "0",
    "1100110": "1",
    "1101100": "2",
    "1000010": "3",
    "1011100": "4",
    "1001110": "5",
    "1010000": "6",
    "1000100": "7",
    "1001000": "8",
    "1110100": "9",
}

FIRST_DIGIT_PATTERNS = {
    "AAAAAA": "0",
    "AABABB": "1",
    "AABBAB": "2",
    "AABBBA": "3",
    "ABAABB": "4",
    "ABBAAB": "5",
    "ABBBAA": "6",
    "ABABAB": "7",
    "ABABBA": "8",
    "ABBABA": "9",
}


def decode_first_digit(left_types):
    pattern = "".join(left_types)
    return FIRST_DIGIT_PATTERNS.get(pattern)


def decode_ean13_from_image(img: np.ndarray):
    _, thresh = cv2.threshold(img, 128, 255, cv2.THRESH_BINARY | cv2.THRESH_OTSU)

    row = thresh[thresh.shape[0] // 2, :]

    binary = np.where(row < 128, 1, 0)

    start = np.where(binary[: len(binary) // 2] == 1)[0][0]
    stop = np.where(binary[len(binary) // 2 :] == 1)[0][-1] + len(binary) // 2
    cols = binary[start:stop]

    module_width = len(cols) / 95
    modules = []
    for i in range(95):
        segment = cols[int(i * module_width) : int((i + 1) * module_width)]
        modules.append(1 if segment.mean() > 0.5 else 0)
    modules = np.array(modules)

    left_digits = []
    left_types = []

    for i in range(3, 45, 7):
        pattern = "".join(map(str, modules[i : i + 7]))
        if pattern in A_CODE:
            left_digits.append(A_CODE[pattern])
            left_types.append("A")
        elif pattern in B_CODE:
            left_digits.append(B_CODE[pattern])
            left_types.append("B")
        else:
            left_digits.append("?")
            left_types.append("?")

    first_digit = decode_first_digit(left_types)

    right_digits = []

    for i in range(50, 92, 7):
        pattern = "".join(map(str, modules[i : i + 7]))
        if pattern in C_CODE:
            right_digits.append(C_CODE[pattern])
        else:
            right_digits.append("?")

    ean13 = first_digit + "".join(left_digits) + "".join(right_digits)
    return ean13
