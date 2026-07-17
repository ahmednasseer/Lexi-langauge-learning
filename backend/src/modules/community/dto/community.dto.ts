import { IsString, IsOptional, MinLength, MaxLength } from 'class-validator';

export class CreatePostDto {
  @IsString()
  @MinLength(1)
  @MaxLength(2000)
  content: string;

  @IsString()
  @MinLength(1)
  @MaxLength(50)
  type: string;

  @IsOptional()
  @IsString()
  groupId?: string;
}

export class AddCommentDto {
  @IsString()
  @MinLength(1)
  @MaxLength(1000)
  text: string;
}

export class SendMessageRequestDto {
  @IsString()
  @MinLength(1)
  receiverId: string;
}

export class SendMessageDto {
  @IsString()
  @MinLength(1)
  receiverId: string;

  @IsString()
  @MinLength(1)
  @MaxLength(1000)
  content: string;
}
