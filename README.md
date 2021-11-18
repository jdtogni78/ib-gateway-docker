# Interactive Brokers Gateway Docker

IB Gateway running in Docker with [IB Controller](https://github.com/ib-controller/ib-controller/) and VNC

* TWS Gateway: v978.2d
* IBC: 3.8.4-beta.2

### Docker Hub image

* https://hub.docker.com/r/forhire/ibgateway

### HELM3 chart for deploying to Kubernetes
* https://github.com/forhire/ibgw

### Getting Started

```bash
> git clone
> cd ib-gateway-docker
> docker build .
> docker-compose up
```

#### Expected output

```bash
Creating ibgatewaydocker_tws_1 ...
Creating ibgatewaydocker_tws_1 ... done
Attaching to ibgatewaydocker_tws_1
tws_1  | Starting virtual X frame buffer: Xvfb.
tws_1  | find: '/opt/IBController/Logs': No such file or directory
tws_1  | stored passwd in file: /.vnc/passwd
tws_1  | Starting x11vnc.
tws_1  |
tws_1  | +==============================================================================
tws_1  | +
tws_1  | + IBController version 3.2.0
tws_1  | +
tws_1  | + Running GATEWAY 960
tws_1  | +
tws_1  | + Diagnostic information is logged in:
tws_1  | +
tws_1  | + /opt/IBController/Logs/ibc-3.2.0_GATEWAY-960_Tuesday.txt
tws_1  | +
tws_1  | +
tws_1  | Forking :::4001 onto 0.0.0.0:4003\n
```

You will now have the IB Gateway app running on port 4003 and VNC on 5901.

See [docker-compose.yml](docker-compose.yml) for configuring VNC password, accounts and trading mode.

Please do not open your box to the internet.

### Testing VNC

* localhost:5901

![vnc](docs/ib_gateway_vnc.jpg)

### Demo Accounts

It seems that all of the `demo` accounts are dead for good:

* edemo
* fdemo
* pmdemo

### Troubleshooting

Sometimes, when running in non-daemon mode, you will see this:

```java
Exception in thread "main" java.awt.AWTError: Can't connect to X11 window server using ':0' as the value of the DISPLAY variable.
```

You will have to remove the container `docker rm container_id` and run `docker-compose up` again.

[DSTrader][prod] Daily Run - Failed - portfolios/portfolio.json - 2021-09-28 12:35:23
[main] 2021-09-28 12:32:21,341 INFO  - isDueByDate nextUpdate=2021-09-28 processingDate=2021-09-28T12:32:21.034911612 IS DUE
[main] 2021-09-28 12:32:21,371 INFO  - ### Plan Report Start
[main] 2021-09-28 12:32:21,374 INFO  -  FTBFX SELL MKT 0.652 est price: $11.15 est total: $7.27
[main] 2021-09-28 12:32:21,374 INFO  -  FIPDX SELL MKT 0.799 est price: $11.44 est total: $9.14
[main] 2021-09-28 12:32:21,374 INFO  - ### Plan Report End
[main] 2021-09-28 12:32:21,378 INFO  - Placing IB order 2 for FTBFX
[main] 2021-09-28 12:32:21,382 INFO  - Placing IB order 3 for FIPDX
[Thread-3] 2021-09-28 12:32:21,600 ERROR - Error id=2 code=10165 msg=Cash Quantity Order can not be used on this security. Please try with regular order.
[Thread-3] 2021-09-28 12:32:21,613 ERROR - Error id=3 code=10165 msg=Cash Quantity Order can not be used on this security. Please try with regular order.
[main] 2021-09-28 12:35:23,319 INFO  - Account U5843610 updated

## api does not support fractions on cashqty