<script setup>
import { ref, computed, onMounted } from "vue";
import {
  Dialog,
  DialogPanel,
  DialogTitle,
  TransitionRoot,
  TransitionChild,
  Listbox,
  ListboxButton,
  ListboxOptions,
  ListboxOption,
} from "@headlessui/vue";
import {
  ChevronUpDownIcon,
  TrashIcon,
  PencilIcon,
  PlusIcon,
  CheckIcon,
  XMarkIcon,
  CheckCircleIcon,
  XCircleIcon,
} from "@heroicons/vue/24/solid";
import {putWithToken, delWithToken, getAllWithToken, postWithToken } from '../../../lib/fetch-api';

// --- Reactive State ---
const users = ref([]);
const searchQuery = ref("");
const isAddUserOpen = ref(false);
const isEditUserOpen = ref(false);
const userTypes = ["Admin", "User"];
const newUserEmail = ref("");
const newUserCompany = ref("");
const newUserType = ref(userTypes[0]);
const currentUser = ref(null);
const editedUserEmail = ref("");
const editedUserCompany = ref("");
const editedUserType = ref(userTypes[0]);

// --- Helper: Fetch Users from Backend ---
const fetchUsers = async () => {
  const response = await getAllWithToken("users", null);
  if (response.isSuccess) {
    users.value = response.body;
  } else {
    alert(response.message);
  }
};

onMounted(async () => {
  await fetchUsers();
});

// --- Handlers ---

const handleAddUser = async () => {
  if (
    !newUserEmail.value.trim() ||
    !newUserCompany.value.trim() ||
    !newUserType.value.trim()
  ) {
    alert("All fields are required.");
    return;
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(newUserEmail.value)) {
    alert("Please enter a valid email address.");
    return;
  }
  const newUser = {
    email: newUserEmail.value.trim(),
    company: newUserCompany.value.trim(),
    is_confirmed: false,
    userType: newUserType.value,
  };
  const response = await postWithToken("users", newUser);
  if (response.isSuccess) {
    newUserEmail.value = "";
    newUserCompany.value = "";
    newUserType.value = userTypes[0];
    isAddUserOpen.value = false;
    await fetchUsers();
  } else {
    alert(response.message);
  }
};

const handleEditUser = async () => {
  if (
    !currentUser.value ||
    !editedUserEmail.value.trim() ||
    !editedUserCompany.value.trim() ||
    !editedUserType.value.trim()
  ) {
    alert("All fields are required.");
    return;
  }
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(editedUserEmail.value)) {
    alert("Please enter a valid email address.");
    return;
  }
  const updatedUser = {
    id: currentUser.value.id,
    email: editedUserEmail.value.trim(),
    company: editedUserCompany.value.trim(),
    is_confirmed: currentUser.value.is_confirmed,
    type: editedUserType.value,
  };
  const result = await putWithToken("users", updatedUser);
  if (result.isSuccess) {
    currentUser.value = null;
    editedUserEmail.value = "";
    editedUserCompany.value = "";
    editedUserType.value = userTypes[0];
    isEditUserOpen.value = false;
    await fetchUsers();
  } else {
    alert(result.message);
  }
};

const handleDeleteUser = async (userId) => {
  if (!confirm("Are you sure you want to delete this user?")) return;
  const response = await delWithToken("users", userId);
  if (response.isSuccess) {
    await fetchUsers();
  } else {
    alert(response.message);
  }
};

const handleToggleConfirmed = async (userId) => {
  const user = users.value.find((u) => u.id === userId);
  if (!user) return;
  const updatedUser = { ...user, is_confirmed: !user.is_confirmed };
  const result = await putWithToken("users", updatedUser);
  if (result.isSuccess) {
    await fetchUsers();
  } else {
    alert(result.message);
  }
};

const editUser = (user) => {
  currentUser.value = user;
  editedUserEmail.value = user.email;
  editedUserCompany.value = user.company;
  editedUserType.value = user.type.charAt(0).toUpperCase() + user.type.slice(1);
  isEditUserOpen.value = true;
};

const filteredUsers = computed(() => {
  if (!searchQuery.value.trim()) {
    return users.value;
  }
  const lowerQuery = searchQuery.value.toLowerCase();
  return users.value.filter((user) => {
    const role = user.type || user.userType || "";
    return (
      user.email.toLowerCase().includes(lowerQuery) ||
      user.company.toLowerCase().includes(lowerQuery) ||
      role.toLowerCase().includes(lowerQuery)
    );
  });
});
</script>

<template>
  <div class="p-8 max-w-7xl mx-auto bg-white-50 rounded-lg min-h-screen flex flex-col">
    <h1 class="text-4xl font-bold text-blue-700 mb-6 text-center">User Management</h1>

    <!-- Search Bar -->
    <div class="mb-6">
      <input
        type="text"
        placeholder="Search users by email, company, or user type..."
        v-model="searchQuery"
        class="w-full p-3 border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
    </div>

    <!-- Action Buttons -->
    <div class="flex space-x-4 mb-6">
      <button
        @click="isAddUserOpen = true"
        class="flex items-center px-4 py-2 bg-blue-500 text-white rounded-lg hover:bg-blue-600 transition-colors"
      >
        <PlusIcon class="h-5 w-5 mr-2" />
        Add User
      </button>
    </div>

    <!-- Users List -->
    <div class="flex-1 space-y-4 overflow-auto">
      <template v-if="filteredUsers.length > 0">
        <ul class="space-y-2">
          <li
            v-for="user in filteredUsers"
            :key="user.id"
            class="flex flex-col md:flex-row items-start md:items-center justify-between p-4 border border-blue-200 rounded-lg bg-white"
          >
            <!-- User Information -->
            <div class="flex-1">
              <h3 class="text-lg font-semibold text-blue-700">{{ user.email }}</h3>
              <p class="text-gray-700">Company: {{ user.company }}</p>
              <p class="text-gray-700">User Type: {{ user.type }}</p>
              <p class="text-gray-700 flex items-center">
                Confirmed:
                <component
                  :is="user.is_confirmed ? CheckCircleIcon : XCircleIcon"
                  class="h-5 w-5 ml-1"
                  :class="user.is_confirmed ? 'text-green-500' : 'text-red-500'"
                />
              </p>
            </div>

            <!-- Action Buttons -->
            <div class="flex space-x-2 mt-2 md:mt-0">
              <button
                @click="editUser(user)"
                class="p-2 bg-blue-400 text-white rounded hover:bg-blue-500 transition-colors"
              >
                <PencilIcon class="h-5 w-5" />
              </button>
              <button
                @click="handleDeleteUser(user.id)"
                class="p-2 bg-red-500 text-white rounded hover:bg-red-600 transition-colors"
              >
                <TrashIcon class="h-5 w-5" />
              </button>
              <button
                @click="handleToggleConfirmed(user.id)"
                :class="[
                  'p-2 rounded transition-colors flex items-center',
                  user.is_confirmed
                    ? 'bg-yellow-300 hover:bg-yellow-400 text-yellow-800'
                    : 'bg-green-300 hover:bg-green-400 text-green-800'
                ]"
              >
                <component
                  :is="user.is_confirmed ? XMarkIcon : CheckIcon"
                  class="h-5 w-5 mr-1"
                />
              </button>
            </div>
          </li>
        </ul>
      </template>
      <template v-else>
        <p class="text-gray-600">No users found matching your criteria.</p>
      </template>
    </div>

    <!-- Add User Modal -->
    <TransitionRoot :show="isAddUserOpen" as="template">
      <Dialog class="relative z-10" @close="isAddUserOpen = false">
        <TransitionChild
          as="template"
          enter="ease-out duration-300"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="ease-in duration-200"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black bg-opacity-25"></div>
        </TransitionChild>

        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4 text-center">
            <TransitionChild
              as="template"
              enter="ease-out duration-300"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="ease-in duration-200"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel
                class="w-full max-w-md transform overflow-hidden rounded-2xl bg-blue-50 p-6 text-left align-middle transition-all"
              >
                <DialogTitle class="text-lg font-medium leading-6 text-blue-700">
                  Add New User
                </DialogTitle>
                <div class="mt-4 space-y-4">
                  <input
                    type="email"
                    placeholder="Email"
                    v-model="newUserEmail"
                    class="w-full p-2 border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  <input
                    type="text"
                    placeholder="Company"
                    v-model="newUserCompany"
                    class="w-full p-2 border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  <Listbox v-model="newUserType">
                    <div class="relative">
                      <ListboxButton
                        class="relative w-full cursor-pointer rounded-lg bg-white py-2 pl-3 pr-10 text-left border border-blue-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                      >
                        <span class="block truncate">{{ newUserType }}</span>
                        <span class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2">
                          <ChevronUpDownIcon class="h-5 w-5 text-blue-400" />
                        </span>
                      </ListboxButton>
                      <ListboxOptions
                        class="absolute mt-1 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-base ring-1 ring-blue-500 ring-opacity-5 focus:outline-none sm:text-sm"
                      >
                        <ListboxOption
                          v-for="(type, idx) in userTypes"
                          :key="idx"
                          :value="type"
                          v-slot="{ active, selected }"
                        >
                          <div
                            :class="`relative cursor-pointer select-none py-2 pl-10 pr-4 ${active ? 'bg-blue-600 text-white' : 'text-blue-900'}`"
                          >
                            <span
                              :class="`block truncate ${selected ? 'font-medium' : 'font-normal'}`"
                            >
                              {{ type }}
                            </span>
                            <span
                              v-if="selected"
                              :class="`absolute inset-y-0 left-0 flex items-center pl-3 ${active ? 'text-white' : 'text-blue-600'}`"
                            >
                              <CheckIcon class="h-5 w-5" />
                            </span>
                          </div>
                        </ListboxOption>
                      </ListboxOptions>
                    </div>
                  </Listbox>
                </div>
                <div class="mt-6 flex justify-end space-x-4">
                  <button
                    type="button"
                    class="inline-flex justify-center rounded-md border border-transparent bg-blue-300 px-4 py-2 text-sm font-medium text-blue-700 hover:bg-blue-400"
                    @click="isAddUserOpen = false"
                  >
                    Cancel
                  </button>
                  <button
                    type="button"
                    class="inline-flex justify-center rounded-md border border-transparent bg-blue-500 px-4 py-2 text-sm font-medium text-white hover:bg-blue-600"
                    @click="handleAddUser"
                  >
                    Add
                  </button>
                </div>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>

    <!-- Edit User Modal -->
    <TransitionRoot :show="isEditUserOpen" as="template">
      <Dialog class="relative z-10" @close="isEditUserOpen = false">
        <TransitionChild
          as="template"
          enter="ease-out duration-300"
          enter-from="opacity-0"
          enter-to="opacity-100"
          leave="ease-in duration-200"
          leave-from="opacity-100"
          leave-to="opacity-0"
        >
          <div class="fixed inset-0 bg-black bg-opacity-25"></div>
        </TransitionChild>

        <div class="fixed inset-0 overflow-y-auto">
          <div class="flex min-h-full items-center justify-center p-4 text-center">
            <TransitionChild
              as="template"
              enter="ease-out duration-300"
              enter-from="opacity-0 scale-95"
              enter-to="opacity-100 scale-100"
              leave="ease-in duration-200"
              leave-from="opacity-100 scale-100"
              leave-to="opacity-0 scale-95"
            >
              <DialogPanel
                class="w-full max-w-md transform overflow-hidden rounded-2xl bg-blue-50 p-6 text-left align-middle transition-all"
              >
                <DialogTitle class="text-lg font-medium leading-6 text-blue-700">
                  Edit User
                </DialogTitle>
                <div class="mt-4 space-y-4">
                  <input
                    type="email"
                    placeholder="Email"
                    v-model="editedUserEmail"
                    class="w-full p-2 border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  <input
                    type="text"
                    placeholder="Company"
                    v-model="editedUserCompany"
                    class="w-full p-2 border border-blue-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
                  />
                  <Listbox v-model="editedUserType">
                    <div class="relative">
                      <ListboxButton
                        class="relative w-full cursor-pointer rounded-lg bg-white py-2 pl-3 pr-10 text-left border border-blue-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 sm:text-sm"
                      >
                        <span class="block truncate">{{ editedUserType }}</span>
                        <span class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-2">
                          <ChevronUpDownIcon class="h-5 w-5 text-blue-400" />
                        </span>
                      </ListboxButton>
                      <Transition as="div" leave="transition ease-in duration-100" leave-from="opacity-100" leave-to="opacity-0">
                        <ListboxOptions
                          class="absolute mt-1 max-h-60 w-full overflow-auto rounded-md bg-white py-1 text-base shadow-none ring-1 ring-blue-500 ring-opacity-5 focus:outline-none sm:text-sm list-none"
                        >
                          <ListboxOption
                            as="li"
                            v-for="(type, idx) in userTypes"
                            :key="idx"
                            :value="type"
                            v-slot="{ active, selected }"
                          >
                            <div
                              :class="`relative cursor-pointer select-none py-2 pl-10 pr-4 ${active ? 'bg-blue-600 text-white' : 'text-blue-900'}`"
                            >
                              <span :class="`block truncate ${selected ? 'font-medium' : 'font-normal'}`">
                                {{ type }}
                              </span>
                              <span
                                v-if="selected"
                                :class="`absolute inset-y-0 left-0 flex items-center pl-3 ${active ? 'text-white' : 'text-blue-600'}`"
                              >
                                <CheckIcon class="h-5 w-5" />
                              </span>
                            </div>
                          </ListboxOption>
                        </ListboxOptions>
                      </Transition>
                    </div>
                  </Listbox>
                </div>
                <div class="mt-6 flex justify-end space-x-4">
                  <button
                    type="button"
                    class="inline-flex justify-center rounded-md border border-transparent bg-blue-300 px-4 py-2 text-sm font-medium text-blue-700 hover:bg-blue-400"
                    @click="isEditUserOpen = false"
                  >
                    Cancel
                  </button>
                  <button
                    type="button"
                    class="inline-flex justify-center rounded-md border border-transparent bg-blue-500 px-4 py-2 text-sm font-medium text-white hover:bg-blue-600"
                    @click="handleEditUser"
                  >
                    Save
                  </button>
                </div>
              </DialogPanel>
            </TransitionChild>
          </div>
        </div>
      </Dialog>
    </TransitionRoot>
  </div>
</template>
