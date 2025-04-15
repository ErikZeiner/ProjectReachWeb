<template>
  <Experiment title="magpie demo">
    <InstructionScreen :title="'Welcome'">
      <p>Thank you for participating in the experiment. It should take you no more than about 10 min to complete.</p>
      <p>Please make sure to wear headphones and be in a quiet environment without distractions – you need to be able to watch short videos with audio.</p>
      <p>Click on the button below to receive instructions.</p>
    </InstructionScreen>

    <InstructionScreen :title="'Instructions'">
      <p> You will be watching a series of short video clips of a speaker uttering simple sentences. The speaker will be framed form below the neck to the waist and you will not see their face.</p>
      <p>Your task is to watch the clips (each will play twice) and answer accompanying questions using a slider marked ‘no’ at one end and ‘yes’ at the other, </p>
      <p>First, you can practice on two clips. </p>
    </InstructionScreen>
    
    <template v-for="(trial, i) of trainingTrials">
      <SliderScreen
        :key = "i"
        :question="'Is the speaker asking whether ' + trial.content + '?'"
        initial="50"
        optionLeft="no"
        optionRight="yes">
      <template #stimulus>

          <video :src="`https://github.com/ErikZeiner/ProjectReachWeb/raw/refs/heads/gh-pages/video/training/${trial.target}_${trial.variant}.mp4`" autoplay/>
          <Record :data="{
                        target: trial.target,
                        variant: trial.variant,
                      }" />
          
      </template>
      
      </SliderScreen>
    </template>
    
    <InstructionScreen :title="'Instructions'">
    <p> Lovely! Press next to start the experiment proper.</p>
    </InstructionScreen>

    <template v-for="(trial, i) of assignedTrials">
      <SliderScreen
        :key = "i"
        :question="'Is the speaker asking whether ' + trial.content + '?'"
        initial="50"
        optionLeft="no"
        optionRight="yes">
      <template #stimulus>
          <video :src="`https://github.com/ErikZeiner/ProjectReachWeb/raw/refs/heads/gh-pages/video/main/${trial.target}_${trial.variant}_${trial.beat}.mp4`" autoplay/>
          <Record :data="{
                        target: trial.target,
                        variant: trial.variant,
                        beat: trial.beat,
                      }" />
      </template>
      </SliderScreen>
    </template>

    <PostTestScreen :education="false" />
    
    
    <SubmitResultsScreen />
  </Experiment>
</template>

<script>
import mainTrials from '../trials/mainTrials.csv'
import trainingTrials from '../trials/trainingTrials.csv'
import _ from 'lodash'
import { ref } from 'vue'

export default {
  name: 'App',
  data() {
    return {
      mainTrials: mainTrials,
      trainingTrials: _.shuffle(trainingTrials),
      participantIndex:0
    }
  },
  mounted() {
    const id = this.$root.magpie?.participant_id || "anon0";
    this.participantIndex = parseInt(id.match(/\d+/)?.[0]) || 0;
  },
  methods: {
    shuffleArray(array) {
      const shuffled = [...array];
      for (let i = shuffled.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
      }
      return shuffled;
    }
  },
  computed: {
      assignedTrials() {
        // Group by target
        const grouped = {};
        this.mainTrials.forEach(trial => {
          if (!grouped[trial.target]) {
            grouped[trial.target] = [];
          }
          grouped[trial.target].push(trial);
        });
        
        const assigned = [];
        
        Object.entries(grouped).forEach(([target, variants], i) => {
          // Sort so A is index 0, B is index 1
          variants.sort((a, b) => a.variant.localeCompare(b.variant));
          
          // Decide which variant gets the video
          const videoIndex = (this.participantIndex + i) % 2;
          
          variants.forEach((trial, j) => {
            assigned.push({
              ...trial,
              beat: j === videoIndex ? 1 : 0
            });
          });
        });
        
        // Shuffle full trial list
        return this.shuffleArray(assigned);
      }
    }
}
</script>