<template>
  <Experiment title="magpie demo">
    <InstructionScreen :title="'Welcome'">
      <p>Thank you for participating in this experiment. It should take you no more than about X min to complete it.</p>
      
      <p>Please make sure to wear headphones and be in a quiet environment without distractions. You need to be able to watch short videos with audio.</p>

      <p>Click on the button below to receive instructions.</p>
    </InstructionScreen>

    <InstructionScreen :title="'Instructions'">
      <p>You will see a series of short video clips. In these clips you will see a speaker uttering a sentence. The speaker will be framed from below the neck to the waist.</p>
      <p>Your task is to watch the clips (each will play twice) and answer accompanying questions. Use the slider to ??????????? </p>
      <p>First, you can practice on two clips. </p>
    </InstructionScreen>
    
    <template v-for="(trial, i) of training_trials">
      <SliderScreen
        :key = "i"
        :question="'Is the speaker asking whether ' + trial.content + '?'"
        initial="50"
        optionLeft="no"
        optionRight="yes">
      <template #stimulus>
          <video :src="trial.clip" autoplay/>
      </template>
      </SliderScreen>
    </template>
    
    <InstructionScreen :title="'Instructions'">
    <p> Lovely! Now you are ready to start the experiment proper.</p>
    </InstructionScreen>

    <template v-for="(trial, i) of main_trials">
      <SliderScreen
        :key = "i"
        :question="'Is the speaker asking whether ' + trial.content + '?'"
        initial="50"
        optionLeft="no"
        optionRight="yes">
      <template #stimulus>
          <video :src="trial.clip" autoplay/>
      </template>
      </SliderScreen>
    </template>

    <PostTestScreen :education="false" />
    
    
      <DebugResultsScreen/>
  </Experiment>
</template>

<script>
import main_trials from '../trials/main_trials.csv'
import training_trials from '../trials/training_trials.csv'
import _ from 'lodash'
import { ref } from 'vue'

export default {
  name: 'App',
  data() {
    return {
      main_trials: _.shuffle(main_trials),
      training_trials: _.shuffle(training_trials),
    }
  }
}
</script>