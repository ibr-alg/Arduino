#ifndef ethernet_h
#define ethernet_h

#include <inttypes.h>
//#include "w5100.h"
#include "IPAddress.h"
#ifndef ARDUINO_LITE
#include "EthernetClient.h"
#include "EthernetServer.h"
#endif
#ifdef ARDUINO_DHCP
#include "Dhcp.h"
#endif

#define MAX_SOCK_NUM 4

class EthernetClass {
private:
  IPAddress _dnsServerAddress;
#ifdef ARDUINO_DHCP
  DhcpClass* _dhcp;
#endif
public:
  static uint8_t _state[MAX_SOCK_NUM];
  static uint16_t _server_port[MAX_SOCK_NUM];
  // Initialise the Ethernet shield to use the provided MAC address and gain the rest of the
  // configuration through DHCP.
  // Returns 0 if the DHCP configuration failed, and 1 if it succeeded
#ifdef ARDUINO_DHCP
  int begin(uint8_t *mac_address);
#endif
#ifndef ARDUINO_LITE
  void begin(uint8_t *mac_address, IPAddress local_ip);
  void begin(uint8_t *mac_address, IPAddress local_ip, IPAddress dns_server);
  void begin(uint8_t *mac_address, IPAddress local_ip, IPAddress dns_server, IPAddress gateway);
#endif
  void begin(uint8_t *mac_address, IPAddress local_ip, IPAddress dns_server, IPAddress gateway, IPAddress subnet);
#ifndef ARDUINO_LITE
  int maintain();
#endif

  IPAddress localIP();
  IPAddress subnetMask();
  IPAddress gatewayIP();
  IPAddress dnsServerIP();

#ifndef ARDUINO_LITE
  friend class EthernetClient;
  friend class EthernetServer;
#endif
};

extern EthernetClass Ethernet;

#endif
