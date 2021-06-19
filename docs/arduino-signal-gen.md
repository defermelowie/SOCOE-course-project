# Arduino signal generator

The generator cycles over an array of 32 bytes.

```
pins = array[0]
wait PERIOD
pins = array[1]
wait PERIOD
...
pins = array[31]
wait PERIOD
pins = array[0]
wait PERIOD
...
```

Data in the array can be changed at runtime by sending `BYTE_INDEX DATA` via the serial connection. For example:
```
>>> 7 17
[INFO] Data[7] = 17

>>> 7 0xaa
[INFO] Data[7] = 170
```