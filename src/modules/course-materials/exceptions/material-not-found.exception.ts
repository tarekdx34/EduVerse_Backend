import { HttpException, HttpStatus } from '@nestjs/common';

export class MaterialNotFoundException extends HttpException {
  constructor(materialId: number) {
    super(
      {
        statusCode: HttpStatus.NOT_FOUND,
        message: `Material with ID ${materialId} not found`,
        error: 'Not Found',
      },
      HttpStatus.NOT_FOUND,
    );
  }
}
