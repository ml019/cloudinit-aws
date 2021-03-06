#!/bin/bash
# Assumes EFS_FILE_SYSTEM_ID - Environment Variable - The ID of the EFS File System 
# Assumes EFS_MOUNT_PATH - Environment Variable - The Path on the EFS File System
# Assumes EFS_OS_MOUNT_PATH - Environment Variable - Location on the OS where the share should mount 
# Assumes amazon-efs-utils has been installed already 

# Mount EFS to a temp directory and create the EFS path if it doesn't exist  
# Thie ensures the permanent mount works as expected
temp_dir="$(mktemp -d -t efs.XXXXXXXX)"
mount -t efs "${EFS_FILE_SYSTEM_ID}:/" ${temp_dir} || exit $?
if [[ ! -d "${temp_dir}/${EFS_MOUNT_PATH}" ]]; then 
    mkdir -p "${temp_dir}/${EFS_MOUNT_PATH}"

    # Allow Full Access to volume (Allows for unkown container access )
    chmod -R ugo+rwx "${temp_dir}/${EFS_MOUNT_PATH}"
fi
umount ${temp_dir}

# Create and Mount volume
mkdir -p ${EFS_OS_MOUNT_PATH}
mount -t efs "${EFS_FILE_SYSTEM_ID}:${EFS_MOUNT_PATH}" "${EFS_OS_MOUNT_PATH}" || exit $?

# Add to permanent mount in case of reboots
echo -e "${EFS_FILE_SYSTEM_ID}:${EFS_MOUNT_PATH} ${EFS_OS_MOUNT_PATH} efs defaults,_netdev 0 0" >> /etc/fstab
