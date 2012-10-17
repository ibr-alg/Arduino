CC=avr-gcc
CXX=avr-g++
#MCU=-mmcu=atmega328p
#CPU_SPEED=-DF_CPU=16000000UL
#VARIANTS=standard

SPI_PATH=libraries/SPI
SD_PATH=libraries/SD
PINS_PATH=hardware/arduino/variants/$(VARIANTS)
WIRING_PATH=hardware/arduino/cores/arduino
ETHERNET_PATH=libraries/Ethernet

STATIC_LIBRARIES=libarduino.a libspi.a libethernet.a libsd.a librawsd.a

HEADER_PATHS=-I$(SPI_PATH) -I$(PINS_PATH) -I$(WIRING_PATH) -I$(ETHERNET_PATH) \
	-I$(ETHERNET_PATH)/utility -I$(SD_PATH) -I$(SD_PATH)/utility
ENABLE_FLAGS=-DARDUINO_WIRING_DIGITAL -DARDUINO_LITE

CFLAGS=-mmcu=$(MCU) -DF_CPU=$(CPU_SPEED) $(ENABLE_FLAGS) -Os -w -funsigned-char \
	-funsigned-bitfields -fpack-struct -fshort-enums -fno-exceptions

ARDUINO_FILES=wiring.c wiring_digital.c HardwareSerial.cpp \
	WInterrupts.c Print.cpp IPAddress.cpp new.cpp

ETHERNET_FILES=Ethernet.cpp EthernetUdp.cpp utility/socket.cpp \
	utility/w5100.cpp 
ETHERNET_SOURCES=$(addprefix $(ETHERNET_PATH)/, $(ETHERNET_FILES))
ETHERNET_OBJECTS=$(ETHERNET_SOURCES:.cpp=.o)

ARDUINO_SOURCES=$(addprefix $(WIRING_PATH)/, $(ARDUINO_FILES))
ARDUINO_OBJECTS1=$(filter %.cpp, $(ARDUINO_SOURCES))
ARDUINO_OBJECTS2=$(filter %.c, $(ARDUINO_SOURCES))
ARDUINO_OBJECTS=$(ARDUINO_OBJECTS1:.cpp=.o) $(ARDUINO_OBJECTS2:.c=.o)

.phony: clean default

default: $(STATIC_LIBRARIES)
	
clean:
	echo ------------- CLEAN
	rm -f libarduino.a libspi.a libethernet.a libsd.a librawsd.a

libarduino.a: $(ARDUINO_OBJECTS)
	echo ------------- LIBARDUINO
	avr-ar rcs $@ $^
	rm $(ARDUINO_OBJECTS)

libspi.a: $(SPI_PATH)/SPI.cpp
	$(CXX) $(HEADER_PATHS) $< $(CFLAGS) -c -o $(SPI_PATH)/SPI.o
	avr-ar rcs $@ $(SPI_PATH)/SPI.o
	rm $(SPI_PATH)/SPI.o
	
libsd.a: $(SD_PATH)/SD.cpp librawsd.a
	@echo --------------------- LIB SD
	$(CXX) $(HEADER_PATHS) $< $(CFLAGS) -c -o $(SD_PATH)/SD.o
	avr-ar rcs $@ $(SD_PATH)/SD.o
	rm $(SD_PATH)/SD.o
	
librawsd.a: $(SD_PATH)/utility/Sd2Card.cpp
	@echo --------------------- LIBRAWSD
	$(CXX) $(HEADER_PATHS) $< $(CFLAGS) -c -o $(SD_PATH)/utility/SD2Card.o
	avr-ar rcs $@ $(SD_PATH)/utility/SD2Card.o
	rm $(SD_PATH)/utility/SD2Card.o

libethernet.a: $(ETHERNET_OBJECTS)
	avr-ar rcs $@ $^
	rm $(ETHERNET_OBJECTS)

$(ETHERNET_PATH)/%.o : $(ETHERNET_PATH)/%.cpp
	$(CXX) $(HEADER_PATHS) $< $(CFLAGS) -c -o $@	

$(WIRING_PATH)/%.o : $(WIRING_PATH)/%.c
	$(CC) $(HEADER_PATHS) $< $(CFLAGS) -c -o $@

$(WIRING_PATH)/%.o : $(WIRING_PATH)/%.cpp
	$(CXX) $(HEADER_PATHS) $< $(CFLAGS) -c -o $@
