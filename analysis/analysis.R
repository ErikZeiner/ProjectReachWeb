library(dplyr)
library(tidyverse)
library(ggplot2)
library(xtable)
library(viridis)


# Expected order, as seen in Tonhauser et al. 2018 (+ training at the end for technical purposes)
target_order <- c('mc', 'establish', 'stop', 'discover', 'know', 'nomappos', 'annoyed', 'training')


# Read data
df_orig <- read.csv('magpie_data.csv') %>%
  mutate(submission_id = as.factor(as.integer(factor(submission_id))),
         beat = as.factor(beat),
         target = factor(target, levels = target_order),
         response = replace_na(response, 50) / 100) %>%
  arrange(submission_id)
# Data inclusion - if participants don't move the slider and click submit, Magpie registers it as NA. The slider is set by default at 50, those values therefore replace the NAs

# Data exclusion
plot(df_orig$responseTime)
slow_responses <- df_orig %>% filter(responseTime > 50000)

min(df_orig$responseTime)
fast_responses <- df_orig %>% filter(responseTime < 5000)
# => No need to exclude based on response time

plot(df_orig$responseTime,df_orig$response)

# overview of answers of each participant
ggplot(df_orig[df_orig$target != 'training',], aes(x = target, y = response, colour = submission_id, shape = beat)) +
  geom_point(size = 3) +
  facet_wrap(~submission_id) +
  guides(colour = "none") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1),
        legend.position = 'bottom') +
  scale_shape_manual(values = c(1, 3), labels = c('No Beat', 'Beat')) +
  labs(
    x = 'Target expression',
    y = 'At-issueness',
    colour = 'Participant Number',
    shape = 'Beat Presence'
  )
ggsave(
  'participants_overview.png',
  plot = last_plot(),
  path = '../figures/',
  scale = 1,
  width = 20,
  height = 23,
  units = 'cm',
  dpi = 300
)


# Participant 1: typo in experiment
df_rem1 <- df_orig %>%
  filter(!(
    submission_id == 1 &
      target == 'nomappos' &
      variant == 'A'))
nrow(df_orig) - nrow(df_rem1) # How many datapoints excluded

# Remove training data

df_rem2 <- df_rem1 %>%
  filter(target != 'training')
nrow(df_rem1) - nrow(df_rem2) # How many datapoints excluded

df_rem2 %>%
  group_by(target, beat) %>%
  filter(response > mean(response) + 3 * sd(response)) %>%
  group_by(submission_id) %>%
  summarise(
    targets = paste(unique(target), collapse = ', '),
    .groups = 'drop'
  )

df_rem2 %>%
  group_by(target, beat) %>%
  filter(response > mean(response) + 2 * sd(response)) %>%
  group_by(submission_id) %>%
  summarise(
    targets = paste(unique(target), collapse = ', '),
    .groups = 'drop'
  )

# Remove participant who interpreted task differently
df <- df_rem2 %>%
  filter(submission_id != 7)
nrow(df_rem2) - nrow(df) # How many datapoints excluded

# Double check distribution of responses
df %>%
  group_by(target, beat) %>%
  summarise(count = n())


df_grouped <- df %>%
  group_by(target, variant, beat) %>%
  summarise(mean = mean(response),
            count = n(),
            participants = paste(sort(unique(submission_id)), collapse = ', '))

ggplot(df_grouped[df_grouped$target != 'mc',], aes(x = variant, y = mean, shape = beat)) +
  geom_point(size = 3) +
  geom_text(aes(label = count),hjust = 2, size = 3) +
  scale_shape_manual(values = c(1, 3), labels = c('No Beat', 'Beat')) +
  facet_wrap(~target) +
  scale_y_continuous(limits = c(0, 1)) +
  labs(
    x = 'Variant',
    y = 'Mean At-issueness',
    shape = 'Beat Presence'
  ) +
  ggtitle('Mean At-issueness', 'Grouped by target, variant, and beat')
# We can see that splitting by variant does not make sense since the split is not equal which has a systematic effect on the resposne value


# General variability check as predicted by Tonhauser et al. 2018
ggplot(df, aes(x = target, y = response)) +
  geom_boxplot() +
  stat_summary(fun = mean, geom = 'point', shape = 19, size = 4) +
  labs(x = 'Target expression', y = 'At-issueness') +
  ggtitle('At-issueness per target expression')

df %>%
  group_by(target) %>%
  summarise(count = n())

df %>%
  group_by(target) %>%
  filter(response >= 0.5) %>%
  summarise(count = n())

ggplot(df[df$target == 'nomappos',], aes(x = beat, y = response)) +
  geom_point() +
  labs(
    x = 'Target expression',
    y = 'At-issueness'
  ) +
  ggtitle('Data for Nominal Appositive')

ggplot(df, aes(x = beat, y = response)) +
  geom_boxplot() +
  stat_summary(fun = mean, geom = 'point', shape = 19, size = 3, color = 'blue') +
  stat_summary(fun = median, geom = "crossbar", width = 0.75, color = "red", size = 0.4) +
  facet_grid(~target) +
  labs(x = 'Beat presence', y = 'At-issueness')
ggsave(
  'beat_per_target.png',
  plot = last_plot(),
  path = '../figures/',
  scale = 1,
  width = 20,
  height = 12,
  units = 'cm',
  dpi = 300
)

# Look at mean and median numerically
mean_median <- df %>%
  group_by(target, beat) %>%
  summarise(
    mean_response = mean(response),
    median_response = median(response),
    .groups = 'drop'
  ) %>%
  pivot_wider(
    names_from = beat,
    values_from = c(mean_response, median_response)
  ) %>%
  mutate(
    mean_diff = mean_response_1 - mean_response_0,
    median_diff = median_response_1 - median_response_0
  ) %>%
  select(target, mean_diff, median_diff)
mean_median
mean_median_df <- as.data.frame(mean_median)
colnames(mean_median_df) <- c('\\textbf{Target expression}', '\\textbf{Mean difference}', '\\textbf{Median difference}')
# print(
#   xtable(mean_median_df, digits=3),
#   include.rownames = FALSE,
#   hline.before = NUll,
#   hline.after = NULL,
#   sanitize.colnames.function = identity,
#   file='../exported_sections/mean_median_table.tex')

# Overview of languages
# sync up formatting for two german + korean speakers
df$languages <- sub('German (Korean)', 'German, Korean', df$languages, fixed = TRUE)

native_table <- table(df[!duplicated(df$submission_id),]$languages)
native_df <- as.data.frame(native_table)
colnames(native_df) <- c('\\textbf{Native language(s)}', '\\textbf{Number of speakers}')
# print(
#   xtable(native_df,caption = c('Number of speakers per each native language/combination of native languages',label='nativetbl')),
#   include.rownames = FALSE,
#   hline.before = NUll,
#   hline.after = NULL,
#   sanitize.colnames.function = identity,
#   file='../exported_sections/languages_table.tex')

# Age ranges
min(df$age)
max(df$age)

# Gender
df %>%
  group_by(submission_id, gender) %>%
  summarise(n = n(), .groups = 'drop') %>%
  count(gender)