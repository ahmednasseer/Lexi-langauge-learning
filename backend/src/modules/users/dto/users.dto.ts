import {
  IsOptional,
  IsString,
  IsInt,
  Min,
  Max,
  MinLength,
  MaxLength,
} from 'class-validator';

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  @MinLength(1)
  @MaxLength(50)
  name?: string;

  @IsOptional()
  @IsString()
  @MaxLength(10)
  nativeLanguage?: string;

  @IsOptional()
  @IsString()
  @MaxLength(10)
  learningLanguage?: string;

  @IsOptional()
  @IsString()
  @MaxLength(50)
  learningGoal?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(100)
  dailyGoal?: number;
}

export class SpendGemsDto {
  @IsInt()
  @Min(1)
  amount: number;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  description?: string;
}
