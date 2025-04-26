import sys
import math
import json

def detect_collision(x1, y1, x2, y2, threshold=50):
    distance = math.sqrt((x1 - x2)**2 + (y1 - y2)**2)
    return {
        "distance": distance,
        "collision": distance < threshold
    }

if __name__ == "__main__":
    input_data = json.loads(sys.argv[1])
    result = detect_collision(**input_data)
    print(json.dumps(result))
