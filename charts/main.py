import matplotlib.pyplot as plt
import numpy as np

x = np.array([50, 100, 200])
y1 = np.array([191.06, 383.53, 724.94])
y2 = np.array([380.63, 715.43, 1480.24])
y3 = np.array([720.01, 1452.71, 2390.95])

z1 = np.array([188.12, 379.88, 707.35])
z2 = np.array([375.75, 698.40, 1442.78])
z3 = np.array([696.90, 1424.82, 2350.05])


plt.figure()

# 32 bits
plt.plot(x, y1, marker='o', linestyle='--', color='green', label='Szerokość transferu: 32 bity')

# 64 bits
plt.plot(x, y2, marker='o', linestyle='--', color='purple', label='Szerokość transferu: 64 bity')

# 128 bits
plt.plot(x, y3, marker='o', linestyle='--', color='blue', label='Szerokość transferu: 128 bitów')

plt.xlabel("Częstotliwość zegara (MHz)")
plt.ylabel("Przepustowość transferu (MB/s)")
plt.legend()
plt.xticks(np.arange(50, 250, 50))
plt.grid(True)
plt.savefig('/home/domin/2025_eng_dbachurski/latex/mm_mm.eps', format='eps')


plt.figure()

# 32 bits
plt.plot(x, z1, marker='o', linestyle='--', color='green', label='Szerokość transferu: 32 bity')

# 64 bits
plt.plot(x, z2, marker='o', linestyle='--', color='purple', label='Szerokość transferu: 64 bity')

# 128 bits
plt.plot(x, z3, marker='o', linestyle='--', color='blue', label='Szerokość transferu: 128 bitów')

plt.xlabel("Częstotliwość zegara (MHz)")
plt.ylabel("Przepustowość transferu (MB/s)")
plt.legend()
plt.xticks(np.arange(50, 250, 50))
plt.grid(True)
plt.savefig('/home/domin/2025_eng_dbachurski/latex/mm_st.eps', format='eps')
