<template lang="pug">
div.task-list
  div.task-controls
    div.control-group
      button.btn-primary(@click="openCreateModal") + New Task
    div.filters
      select(v-model="filterStatus")
        option(value="") All Status
        option(value="todo") Todo
        option(value="done") Done
      select(v-model="filterCategory")
        option(value="") All Categories
        option(v-for="cat in availableCategories" :key="cat" :value="cat") {{ cat }}
      select(v-model="filterAssignee")
        option(value="") All Assignees
        option(v-for="user in organizationUsers" :key="user.id" :value="user.id") {{ user.name }}

  div(v-if="loading") Loading tasks...
  div(v-else-if="filteredTasks.length === 0") No tasks found.

  div.tasks-grid(v-else)
    div.task-card(v-for="task in filteredTasks" :key="task.id" :class="task.status")
      div.card-header
        div
          h4 {{ task.title }}
          span.category-badge(v-if="task.category") {{ task.category }}
        span.status-badge {{ task.status }}
      p {{ task.description }}
      div.assignee-info(v-if="task.assignee_id")
        span.assignee-label Assigned to: {{ getAssigneeName(task.assignee_id) }}
      div.card-footer
        div.actions
          button.button-complete(@click="toggleStatus(task)") {{ task.status === 'todo' ? 'Complete' : 'Reopen' }}
          button.button-edit(@click="openEditModal(task)") Edit
          button.button-delete(@click="deleteTask(task.id)") Delete

  // Modal for Create/Edit Task
  div.modal-overlay(v-if="showModal" @click.self="closeModal")
    div.modal
      h3 {{ isEditing ? 'Edit Task' : 'Create Task' }}
      input(v-model="formTask.title" placeholder="Title")
      textarea(v-model="formTask.description" placeholder="Description")
      input(v-model="formTask.category" placeholder="Category (e.g. Design, Dev)")
      
      label Assignee (select to invite):
      select(v-model="formTask.assignee_id")
        option(value="") Unassigned
        option(v-for="user in allUsers" :key="user.id" :value="user.id") 
          | {{ user.name }} {{ isUserInOrg(user.id) ? '' : '(will be invited)' }}

      div.modal-actions
        button.btn-primary(@click="saveTask") {{ isEditing ? 'Update' : 'Create' }}
        button.btn-secondary(@click="closeModal") Cancel
</template>

<script setup>
import { ref, watch, computed, onMounted, onUnmounted } from 'vue';
import { useTaskStore } from '../stores/task';
import { useOrganizationStore } from '../stores/organization';
import { storeToRefs } from 'pinia';

const taskStore = useTaskStore();
const orgStore = useOrganizationStore();
const { tasks, loading } = storeToRefs(taskStore);
const { currentOrganization, organizationUsers, allUsers } = storeToRefs(orgStore);

// Modal State
const showModal = ref(false);
const isEditing = ref(false);
const formTask = ref({
    id: null,
    title: '',
    description: '',
    category: '',
    due_date: '',
    assignee_id: ''
});

// Filters
const filterStatus = ref("");
const filterCategory = ref("");
const filterAssignee = ref("");

// Computed
const availableCategories = computed(() => {
    const cats = tasks.value.map(t => t.category).filter(c => c);
    return [...new Set(cats)];
});

const filteredTasks = computed(() => {
    return tasks.value.filter(task => {
        const matchStatus = !filterStatus.value || task.status === filterStatus.value;
        const matchCategory = !filterCategory.value || task.category === filterCategory.value;
        const matchAssignee = !filterAssignee.value || task.assignee_id === filterAssignee.value;
        return matchStatus && matchCategory && matchAssignee;
    });
});

const getAssigneeName = (userId) => {
    const user = allUsers.value.find(u => u.id === userId) || organizationUsers.value.find(u => u.id === userId);
    return user ? user.name : 'Unknown';
};

const isUserInOrg = (userId) => {
    return organizationUsers.value.some(u => u.id === userId);
};

// Fetch tasks when organization changes
watch(currentOrganization, (newOrg) => {
    if (newOrg) {
        taskStore.fetchTasks(newOrg.id);
    }
}, { immediate: true });

// Fetch all users once for invite dropdown
let pollingInterval = null;

onMounted(() => {
    orgStore.fetchAllUsers();
    pollingInterval = setInterval(() => {
        if (currentOrganization.value && !showModal.value) {
            // Silently fetch tasks (maybe add a silent flag to fetchTasks if we don't want spinner)
            // For now, simple fetch is okay
            taskStore.fetchTasks(currentOrganization.value.id); 
        }
    }, 10000); // Poll every 10 seconds
});

onUnmounted(() => {
    if (pollingInterval) clearInterval(pollingInterval);
});


// Modal Logic
const openCreateModal = () => {
    isEditing.value = false;
    formTask.value = { title: '', description: '', category: '', due_date: '', assignee_id: '' };
    showModal.value = true;
};

const openEditModal = (task) => {
    isEditing.value = true;
    formTask.value = { 
        id: task.id,
        title: task.title, 
        description: task.description, 
        category: task.category,
        assignee_id: task.assignee_id || '',
        due_date: task.due_date ? task.due_date.substring(0, 10) : '' 
    };
    showModal.value = true;
};

const closeModal = () => {
    showModal.value = false;
};

const saveTask = async () => {
    if (!currentOrganization.value || !formTask.value.title) return;

    if (isEditing.value) {
        await taskStore.updateTask(currentOrganization.value.id, formTask.value.id, formTask.value);
    } else {
        await taskStore.createTask(currentOrganization.value.id, formTask.value);
    }
    closeModal();
};

const toggleStatus = (task) => {
    const newStatus = task.status === 'todo' ? 'done' : 'todo';
    taskStore.updateTask(currentOrganization.value.id, task.id, { status: newStatus });
};

const deleteTask = (taskId) => {
    if (confirm('Are you sure?')) {
        taskStore.deleteTask(currentOrganization.value.id, taskId);
    }
};

const formatDate = (dateString) => {
    if (!dateString) return '';
    return new Date(dateString).toLocaleDateString();
};
</script>

<style scoped>
/* Task List specific styles matching the new dashboard look */
.task-list {
  margin-top: 20px;
}
.task-controls {
  margin-bottom: 25px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 15px;
}
.filters {
  display: flex;
  gap: 10px;
}
.filters select {
  padding: 8px 12px;
  border: 1px solid #ddd;
  border-radius: 6px;
  background-color: white;
  min-width: 130px;
}
.btn-primary {
  background-color: #42b983;
  color: white;
  padding: 10px 20px;
  border-radius: 6px;
  border: none;
  font-weight: 500;
  display: flex;
  align-items: center;
  gap: 5px;
  box-shadow: 0 2px 4px rgba(66, 185, 131, 0.2);
  cursor: pointer;
}
.btn-primary:hover {
  background-color: #3aa876;
  transform: translateY(-1px);
}

.tasks-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 25px;
}

.task-card {
  border: 1px solid #eaeaea;
  border-radius: 10px;
  padding: 20px;
  background: white;
  box-shadow: 0 2px 5px rgba(0,0,0,0.03);
  transition: transform 0.2s, box-shadow 0.2s;
  display: flex;
  flex-direction: column;
}

.task-card:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 15px rgba(0,0,0,0.05);
  border-color: #ddd;
}

.task-card.done {
  background: #fafafa;
  opacity: 0.8;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 12px;
}

.card-header h4 {
  margin: 0;
  font-size: 1.1rem;
  color: #333;
  line-height: 1.4;
}

.category-badge {
  display: inline-block;
  font-size: 0.7rem;
  padding: 2px 6px;
  border-radius: 4px;
  background: #eef2ff;
  color: #4f46e5;
  margin-top: 4px;
}

.status-badge {
  font-size: 0.75rem;
  padding: 3px 8px;
  border-radius: 12px;
  background: #f0f0f0;
  color: #666;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  white-space: nowrap;
}

.done .status-badge {
  background: #dcfce7;
  color: #166534;
}

.task-card p {
  color: #666;
  font-size: 0.95rem;
  line-height: 1.5;
  margin: 0 0 15px 0;
  flex: 1; /* Push footer down */
}

.card-footer {
  margin-top: auto;
  display: flex;
  justify-content: space-between;
  align-items: center;
  border-top: 1px solid #f5f5f5;
  padding-top: 15px;
  font-size: 0.85rem;
  color: #999;
}

.actions {
  display: flex;
  gap: 8px;
}

.actions button {
  padding: 6px 12px;
  font-size: 0.85rem;
  border-radius: 4px;
  border: 1px solid #ddd;
  background: white;
  cursor: pointer;
}

.button-complete:hover {
  border-color: #bbb;
  color: #333;
}

.button-edit {
  color: #2563eb;
  border-color: #dbeafe;
}
.button-edit:hover {
  background-color: #eff6ff;
}

.button-delete {
  border-color: #fee2e2;
  color: #ef4444;
}
.button-delete:hover {
  background: #fef2f2;
}


/* Modal */
.modal-overlay {
  position: fixed;
  top: 0; left: 0;
  width: 100%; height: 100%;
  background: rgba(0,0,0,0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 100;
  backdrop-filter: blur(2px);
}

.modal {
  background: white;
  padding: 30px;
  border-radius: 12px;
  width: 450px;
  box-shadow: 0 10px 25px rgba(0,0,0,0.1);
}

.modal h3 {
  margin-top: 0;
  margin-bottom: 20px;
  color: #333;
}

.modal input, .modal textarea {
  width: 100%;
  margin-bottom: 15px;
  padding: 10px 12px;
  box-sizing: border-box;
  display: block;
}

.modal textarea {
  height: 100px;
  resize: vertical;
}

.modal-actions {
  display: flex;
  justify-content: flex-end;
  gap: 12px;
  margin-top: 10px;
}

.btn-secondary {
  background-color: #f5f5f5;
  color: #666;
  border: none;
  padding: 10px 20px;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
}
.btn-secondary:hover {
  background-color: #e5e5e5;
}
</style>
