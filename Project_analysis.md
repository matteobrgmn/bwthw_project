# Biomedical wearable design for healthcare and wellbeing
## Goal 2.2
Sustainable Development Goal 2 (Zero Hunger: End hunger, achieve food security and improved nutrition and promote sustainable agriculture), Target 2.2 (By 2030, end all forms of malnutrition, including achieving, by 2025, the internationally agreed targets on stunting and wasting in children under 5 years of age, and address the nutritional needs of adolescent girls, pregnant and lactating women and older persons). For more information see: https://sdgs.un.org/goals/goal2. (Max number of groups: 4)

## Project analysis

Available data:
- Calories
- Distance
- Heart rate
- Exercise session
- Resting heart rate
- Sleep
- Steps

Your project must use at least 1 type of data

Use:
- Calories
- Steps
- Exercise session?
- Meals? (manually input calories/macros)
To do:
1. Ask periodically height and weight with this calculate the BMI(peso(kg)/altezza^2(m)).
Create graphs to monitor the weight and BMI over the time.
2. Find a way to estimate the needed calories and try to verify if we are under or over a threshold. (Could make addition if the user is in pregnancy, to address the initial open issue?) (BMR (Women)=(10×weight in kg)+(6.25×height in cm)−(5×age in years)−161, or BMR (Men)=(10×weight in kg)+(6.25×height in cm)−(5×age in years)+5, factoring physical activity by using a constant (can use data to estimate physical activity?))
3. Set up a goal (by the user) for daily steps, create warning if the steps are too low
4. Create warnings if the exercies or steps are too intense to avoid malnutrional risks
5. Create a 'Streak' system with a small pet or something similar.. keep doing steps and activity to save the pet

Notes:
- Create a list with phrases (and icons?) to use for each warnings, so they aren't always the same


App structure

### 1. Login page

In the login page the user has two choices: login or signup.
If he select the login, he must insert "username" and "password"
otherwise he creates a new account with "username" and "password".
The account datas are stored by the shared preferences.

### 2. Home page

In this page the user can visualize:
- A graph showing the steps for the last week (7days) with the goal
 <br> function getStepBtwTwoDays
- A widget showing the daily calories
- A widget showing the daily steps (so the user has immediatly the number)
- A widget showing his weight
- Navigation bar (equal for all the application):
    - home on the middle
    - user personal data page
    - right?

### 3. User personal datas settings page and visualization

In this page the user can add:
- weight,
- height,
- age, 
- steps goal.

### 4. Page for entering meals

On this page, the user can add meals:
- breakfast,
- lunch,
- dinner.

The calories are summed to obtain the daily total and compared with the calories burned.



### Pagina per inserire i pasti
### Pop-up alert (fuori dall'app)
### Pop-up per chiedere aggiornamento peso


Note: 
- Nell'home page togliere il pop altrimenti torna alla login page



