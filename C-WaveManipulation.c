#include <stdio.h>
#include <stdint.h>

typedef struct WHEADER      // 44 B
{
  uint8_t chunkID[4];       // 4 B
  uint32_t chunkSize;       // 4 B
  uint8_t format[4];        // 4 B
  uint8_t subchunk1ID[4];   // 4 B
  uint32_t subchunk1Size;   // 4 B
  uint16_t audioFormat;     // 2 B
  uint16_t numChannels;     // 2 B
  uint32_t sampleRate;      // 4 B
  uint32_t byteRate;        // 4 B
  uint16_t blockAlign;      // 2 B
  uint16_t bitsPerSample;   // 2 B
  uint8_t subchunk2ID[4];   // 4 B
  uint32_t subchunk2Size;   // 4 B
} WAVHEADER;

int main(int argc, char* argv[])
{
  const char* filename1 = "./Input/W1.wav";
  const char* filename2 = "./Input/W2.wav";
  const char* filename3 = "./Output/C-W3.wav";

  FILE* fileW1 = fopen(filename1, "rb");
  FILE* fileW2 = fopen(filename2, "rb");
  FILE* fileW3 = fopen(filename3, "wb");

  int32_t w1 = 0;
  int32_t w2 = 0;
  int16_t data = 0;
  int64_t length = 0;
  WAVHEADER header;

  // feof() returns a non-zero value when EOF indicator associated with the stream is set, else returns zero.
  while ((w1 = feof(fileW1)) == 0 && (w2 = feof(fileW2)) == 0)
  {
    fread(&data, 2, 1, fileW1);
    fread(&data, 2, 1, fileW2);
    length++;
  }

  fseek(fileW1, 0, SEEK_SET);
  fseek(fileW2, 0, SEEK_SET);

  // W1 is shorter.
  if (w1 != 0)
  {
    fread(&header, 44, 1, fileW1);
    fwrite(&header, 44, 1, fileW3);
  }

  // W2 is shorter.
  if (w2 != 0)
  {
    fread(&header, 44, 1, fileW2);
    fwrite(&header, 44, 1, fileW3);
  }

  int64_t w2_sum = 0;
  int64_t w2_count = 0;

  fseek(fileW2, 44, SEEK_SET); // SEEK_SET represents beggining of the file.

  while(!feof(fileW2))
  {
    fread(&data, 2, 1, fileW2);
    w2_sum += data;
    w2_count++;
  }

  int64_t w2_average = w2_sum / w2_count;

  fseek(fileW1, 44, SEEK_SET);
  fseek(fileW2, 44, SEEK_SET);

  int16_t dataW1;
  int16_t dataW2;

  for (int64_t i = 0; i < length; i++)
  {
    fread (&dataW1, 2, 1, fileW1);
    fread (&dataW2, 2, 1, fileW2);

    if (dataW1 >= w2_average)
      fwrite(&dataW1, 2, 1, fileW3);

    else
      fwrite(&dataW2, 2, 1, fileW3);
  }

  fclose(fileW1);
  fclose(fileW2);
  fclose(fileW3);

  return 0;
}
