from typing import Any, Optional
from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    status: str = Field(..., examples=["ok"])


class ExtractResponse(BaseModel):
    success: bool = Field(..., examples=[True])
    message: str = Field(..., examples=["Examples extracted successfully."])
    file: Optional[str] = Field(default=None, examples=["examples_ab12cd34.pdf"])
    download_url: Optional[str] = Field(default=None, examples=["/download/examples_ab12cd34.pdf"])
    data: Optional[Any] = None