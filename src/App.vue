<template>
  <Experiment title="magpie demo">
  
    <InstructionScreen :title="'Welcome'">
    <p>Thank you for participating in this experiment! It should take no more than 10 minutes to complete.</p>
    <p>Please ensure you are wearing headphones and are in a quiet environment free from distractions. You will need to watch short videos with audio during the experiment.</p>
    <p>Click the button below to see the instructions.</p>
    </InstructionScreen>

    <InstructionScreen :title="'Instructions'">
      <p>In this experiment, you will watch a series of short video clips of a speaker uttering sentences. The speaker will be framed from below the neck to the waist, so their face will not be visible.</p>
      <p>Your task is to watch each clip (each will play twice) and answer accompanying questions using a slider. The slider allows you to indicate your response on a scale between 'yes' and 'no' and express how strongly you feel about your response. </p>
      <p>Before starting the main task, you will practice with two clips.</p>
      <p>NOTE: If you don't see the clips right away, they might be loading and will appear in a few seconds.</p>
    </InstructionScreen>
    
    <template v-for="(trial, i) of trainingTrials">
      <Screen>
          <Slide>
                <video :src="`https://github.com/ErikZeiner/ProjectReachWeb/raw/refs/heads/gh-pages/video/training/${trial.target}_${trial.variant}.mp4`" autoplay/>
                <Record :data="{
                              target: trial.target,
                              variant: trial.variant,
                              beat: 1
                            }" />
                            
            <p>Is the speaker asking whether {{trial.content}}?</p>
            
            <SliderInput
                :initial=50
                left="no"
                right="yes"
                :response.sync= "$magpie.measurements.response" />

            <button @click="$magpie.saveAndNextScreen();">Submit</button>
          </Slide>
      </Screen>
    </template>
    
    <InstructionScreen :title="'Instructions'">
    <p> Lovely! You are all set.</p>
    <p>Now, click the button below to start the main task.</p>
    </InstructionScreen>

    <template v-for="(trial, i) of assignedTrials">
      <Screen
      :progress="i / assignedTrials.length">
          <Slide>
                <video :src="`https://github.com/ErikZeiner/ProjectReachWeb/raw/refs/heads/gh-pages/video/main/${trial.target}_${trial.variant}_${trial.beat}.mp4`" autoplay/>
                <Record :data="{
                              target: trial.target,
                              variant: trial.variant,
                              beat: trial.beat
                            }" />
                            
            <p>Is the speaker asking whether {{trial.content}}?</p>
            
            <SliderInput
                :initial=50
                left="no"
                right="yes"
                :response.sync= "$magpie.measurements.response" />
                
            <button @click="$magpie.saveAndNextScreen();">Submit</button>
          </Slide>
      </Screen>
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
        
        Object.entries(grouped).forEach(([target, variants]) => {
            // Randomly decide which of the variants gets beat
            const randomIndex = Math.floor(Math.random() * variants.length);
            variants.forEach((trial, index) => {
            assigned.push({
              ...trial,
              beat: index === randomIndex ? 1 : 0
              });
            });
        });
        
        return _.shuffle(assigned);
      }
    }
}
</script>