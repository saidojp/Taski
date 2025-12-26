<template lang="pug">
div.auth-container
  h1 Sign Up
  form(@submit.prevent="handleSignup")
    div.form-group
      label Name
      input(v-model="name" type="text" required)
    div.form-group
      label Email
      input(v-model="email" type="email" required)
    div.form-group
      label Password
      input(v-model="password" type="password" required)
    div.form-group
      label Confirm Password
      input(v-model="passwordConfirmation" type="password" required)
    
    button(type="submit") Create Account
  p
    | Already have an account? 
    router-link(to="/login") Login
</template>

<script setup>
import { ref } from 'vue';
import { useAuthStore } from '../stores/auth';
import { useRouter } from 'vue-router';

const name = ref('');
const email = ref('');
const password = ref('');
const passwordConfirmation = ref('');

const authStore = useAuthStore();
const router = useRouter();

const handleSignup = async () => {
  if (password.value !== passwordConfirmation.value) {
    alert("Passwords do not match");
    return;
  }

  try {
    await authStore.signup(name.value, email.value, password.value, passwordConfirmation.value);
    router.push('/dashboard');
  } catch (error) {
    alert('Signup failed: ' + (error.response?.data?.errors?.join(', ') || 'Unknown error'));
  }
};
</script>

<style scoped>
.auth-container {
  max-width: 400px;
  margin: 50px auto;
  padding: 20px;
  border: 1px solid #ddd;
  border-radius: 8px;
}
.form-group {
  margin-bottom: 15px;
}
.form-group label {
  display: block;
  margin-bottom: 5px;
}
.form-group input {
  width: 100%;
  padding: 8px;
  box-sizing: border-box;
}
button {
  width: 100%;
  padding: 10px;
  background-color: #42b983;
  color: white;
  border: none;
  cursor: pointer;
}
</style>
