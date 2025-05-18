
import matplotlib.pyplot as plt

# Simulated Hopify v15 Agile Burndown Chart (v1)

# Project timeline: 15 project days (0 to 14)
days = list(range(0, 15))

# Ideal burndown: Straight line from total tasks (11) to 0 over 15 days
ideal_burndown = [11 - (11/14)*i for i in range(15)]

# Actual burndown: Simulated realistic task completion with mid-project stall and end catch-up
actual_burndown = [11, 10, 9, 9, 8, 8, 7, 6, 5, 5, 4, 3, 2, 1, 0]

# Create the plot
plt.figure(figsize=(10, 6))
plt.plot(days, ideal_burndown, label='Ideal Burndown (v1)', linestyle='--')
plt.plot(days, actual_burndown, label='Actual Burndown (v1)', marker='o')

# Customize chart
plt.title('Hopify v15 Agile Burndown Chart (v1)')
plt.xlabel('Project Day')
plt.ylabel('Remaining Tasks')
plt.xticks(days)
plt.yticks(range(0, 12))
plt.grid(True)
plt.legend()
plt.tight_layout()

# Display chart
plt.show()
