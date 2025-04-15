<template>
  <Experiment title="magpie demo">
    <InstructionScreen :title="'Welcome'">
    <p>Thank you for participating in this experiment! It should take no more than 10 minutes to complete.</p>
    <p>Please ensure you are wearing headphones and are in a quiet environment free from distractions. You will need to watch short videos with audio during the experiment.</p>
    <p>Click the button below to proceed to the instructions.</p>
    </InstructionScreen>

    <InstructionScreen :title="'Instructions'">
      <p>In this experiment, you will watch a series of short video clips of a speaker uttering sentences. The speaker will be framed from below the neck to the waist, so their face will not be visible.</p>
      <p>Your task is to watch each clip (each will play twice) and answer accompanying questions using a slider. The slider allows you to indicate your response on a scale between 'Yes' and 'No' and express how strongly you feel about your response. </p>
      <p>Before starting the main task, you will have the opportunity to practice with two clips.</p>
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
                        beat: 1
                      }" />
          
      </template>
      </SliderScreen>
    </template>
    
    <InstructionScreen :title="'Instructions'">
    <p> Lovely!</p>
    <p>Now, please press NEXT to start the main task.</p>
    </InstructionScreen>

    <template v-for="(trial, i) of assignedTrials">
      <SliderScreen
        :key = "i"
        :question="'Is the speaker asking whether ' + trial.content + '?'"
        initial="50"
        optionLeft="no"
        optionRight="yes"
        :progress="i / assignedTrials.length">
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