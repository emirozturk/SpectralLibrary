class Data:
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y

    def to_dict(self):
        return {"x": self.x, "y": self.y}
    
    @classmethod
    def from_dict(cls, data):
        return cls(x=data["x"], y=data["y"])
