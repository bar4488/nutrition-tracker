from typing import List, OrderedDict
from img2table.ocr import VisionOCR
from img2table.tables.objects.extraction import TableCell
import os
api_key = os.environ["GOOGLE_API_KEY"]
print(api_key)

ocr = VisionOCR(api_key=api_key, timeout=15) # assume api key is given in environment variable `GOOGLE_APPLICATION_CREDENTIALS`

image_path = "C:/Users/bar44/Downloads/table.jpeg"

from img2table.document import Image

# Instantiation of the image
img = Image(src=image_path)

tables = img.extract_tables(ocr=ocr)
print(tables)
def print_table(table: OrderedDict[int, List[TableCell]]):
    maxes = [0] * len(table[0])
    for cells in table.values():
        for idx, item in enumerate(cells):
            item.value = item.value.replace("|", " ")
            value = item.value
            value = []
            # printing in hebrew:
            is_rtl = None
            for word in item.value.split():
                if set(word) & set("אבגדהוזחטיכלמנסעפצקרשתןםץף"):
                    if is_rtl is None:
                        is_rtl = True
                    value.append(word[::-1])
                else:
                    if is_rtl is None and not word.isnumeric():
                        is_rtl = False
                    value.append(word)
            if is_rtl:
                item.value = " ".join(value[::-1])
            else:
                item.value = " ".join(value)
            maxes[idx] = max(len(item.value), maxes[idx])
    
    edge = "|" + "-" * (sum(maxes) + 3 * (len(maxes)) - 1) + "|"
    print(edge)
    for cells in table.values():
        line = "|"
        for idx, item in enumerate(cells):
            line += " " + item.value + " " * (maxes[idx] - len(item.value) + 1) + "|"
        print(line)
    print(edge)

print_table(tables[0].content)