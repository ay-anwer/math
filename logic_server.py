from fastapi import FastAPI
import uvicorn

app = FastAPI()

@app.post("/process")
def calculate_expression(data: dict):
    text = data.get("text", "")
    try:
        # بنعمل eval للـ entry وبنحول النتيجة لـ String
        calculated_result = str(eval(text))
    except Exception as e:
        # لو فيه خطأ في المعادلة (زي قسمة على صفر أو رموز غير مفهومة)
        calculated_result = "Error"

    return {"result": calculated_result}

if __name__ == "__main__":
    uvicorn.run(app, host="127.0.0.1", port=8000)
