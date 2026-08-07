package com.meowarex.rlmobile.ui.screens.patchopts

import android.os.Parcelable
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.ui.draw.clip
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import cafe.adriel.voyager.core.screen.Screen
import cafe.adriel.voyager.koin.koinScreenModel
import cafe.adriel.voyager.navigator.LocalNavigator
import cafe.adriel.voyager.navigator.currentOrThrow
import com.meowarex.rlmobile.R
import com.meowarex.rlmobile.ui.components.*
import com.meowarex.rlmobile.ui.screens.componentopts.PatchComponent
import com.meowarex.rlmobile.ui.screens.patching.PatchingScreen
import androidx.compose.runtime.saveable.rememberSaveable
import com.meowarex.rlmobile.ui.screens.patchopts.components.PackageNameStateLabel
import com.meowarex.rlmobile.ui.screens.patchopts.components.PackageNameUnlockDialog
import com.meowarex.rlmobile.ui.screens.patchopts.components.PatchOptionsAppBar
import com.meowarex.rlmobile.ui.screens.patchopts.components.PatchSelectionAccordion
import com.meowarex.rlmobile.ui.screens.patchopts.components.options.*
import com.meowarex.rlmobile.ui.util.spacedByLastAtBottom
import kotlinx.parcelize.IgnoredOnParcel
import kotlinx.parcelize.Parcelize
import org.koin.core.parameter.parametersOf

@Parcelize
class PatchOptionsScreen(
    private val prefilledOptions: PatchOptions? = null,
) : Screen, Parcelable {
    @IgnoredOnParcel
    override val key = "PatchOptions"

    @Composable
    override fun Content() {
        val navigator = LocalNavigator.currentOrThrow
        val model = koinScreenModel<PatchOptionsModel> { parametersOf(prefilledOptions ?: PatchOptions.Default) }

        PatchOptionsScreenContent(
            isUpdate = prefilledOptions != null,
            isDevMode = model.isDevMode,

            debuggable = model.debuggable,
            setDebuggable = model::changeDebuggable,
            bypassIncompatible = model.bypassIncompatible,
            setBypassIncompatible = model::changeBypassIncompatible,

            appName = model.appName,
            appNameIsError = model.appNameIsError,
            setAppName = model::changeAppName,

            packageName = model.packageName,
            packageNameState = model.packageNameState,
            setPackageName = model::changePackageName,

            packageNameLocked = model.packageNameLocked,
            onUnlockPackageName = model::unlockPackageName,
            onLockPackageName = model::lockPackageName,

            customTidalApk = model.customTidalApk,
            customPatches = model.customPatches,
            onSelectCustomTidalApk = { model.selectCustomTidalApk(navigator) },
            onSelectCustomPatches = { model.selectCustomPatches(navigator) },
            selectedIconId = model.selectedIconId,
            onSelectIcon = model::selectIcon,

            specs = model.specs,
            isPatchEnabled = model::isPatchEnabled,
            onTogglePatch = model::setPatchEnabled,
            patchLockState = model::lockState,
            variantIndex = model::variantIndex,
            onSelectVariant = model::selectVariant,
            optionState = model.optionState,

            isConfigValid = model.isConfigValid,
            onInstall = {
                navigator.push(PatchingScreen(model.generateConfig()))
            },
        )
    }
}

@Composable
fun PatchOptionsScreenContent(
    isUpdate: Boolean,
    isDevMode: Boolean,

    debuggable: Boolean,
    setDebuggable: (Boolean) -> Unit,
    bypassIncompatible: Boolean,
    setBypassIncompatible: (Boolean) -> Unit,

    appName: String,
    appNameIsError: Boolean,
    setAppName: (String) -> Unit,

    packageName: String,
    packageNameState: PackageNameState,
    setPackageName: (String) -> Unit,

    packageNameLocked: Boolean,
    onUnlockPackageName: () -> Unit,
    onLockPackageName: () -> Unit,

    customTidalApk: PatchComponent?,
    onSelectCustomTidalApk: () -> Unit,
    customPatches: PatchComponent?,
    onSelectCustomPatches: () -> Unit,
    selectedIconId: String?,
    onSelectIcon: (String?) -> Unit,

    specs: List<PatchSpec>,
    isPatchEnabled: (PatchSpec) -> Boolean,
    onTogglePatch: (PatchSpec, Boolean) -> Unit,
    patchLockState: (PatchSpec) -> PatchLock,
    variantIndex: (PatchSpec) -> Int,
    onSelectVariant: (PatchSpec, Int) -> Unit,
    optionState: PatchOptionState,

    isConfigValid: Boolean,
    onInstall: () -> Unit,
) {
    var showPkgUnlockDialog by rememberSaveable { mutableStateOf(false) }
    if (showPkgUnlockDialog) {
        PackageNameUnlockDialog(
            // With "Bypass Incompatible" on, path-gated patches are force-applied, not disabled.
            blockedTitles = if (bypassIncompatible) emptyList() else specs.filter { it.pathLocked }.map { it.title },
            onConfirm = {
                showPkgUnlockDialog = false
                onUnlockPackageName()
            },
            onDismiss = { showPkgUnlockDialog = false },
        )
    }

    Scaffold(
        topBar = { PatchOptionsAppBar(isUpdate = isUpdate) },
    ) { paddingValues ->
        Column(
            verticalArrangement = Arrangement.spacedByLastAtBottom(20.dp),
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(paddingValues)
                .padding(horizontal = 20.dp, vertical = 10.dp)
        ) {
            Text(
                text = stringResource(R.string.patchopts_title),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
            )

            TextDivider(text = stringResource(R.string.patchopts_divider_basic))

            val appNameIsDefault by remember {
                derivedStateOf {
                    appName == PatchOptions.Default.appName
                }
            }
            TextPatchOption(
                name = stringResource(R.string.patchopts_appname_title),
                description = stringResource(R.string.patchopts_appname_desc),
                value = appName,
                valueIsError = appNameIsError,
                valueIsDefault = appNameIsDefault,
                onValueChange = setAppName,
                onValueReset = { setAppName(PatchOptions.Default.appName) },
            )

            if (!isUpdate) {
                val packageNameIsDefault by remember {
                    derivedStateOf {
                        packageName == PatchOptions.Default.packageName
                    }
                }
                TextPatchOption(
                    name = stringResource(R.string.patchopts_pkgname_title),
                    description = stringResource(R.string.patchopts_pkgname_desc),
                    value = packageName,
                    valueIsError = packageNameState == PackageNameState.Invalid,
                    valueIsDefault = packageNameIsDefault,
                    onValueChange = setPackageName,
                    onValueReset = { setPackageName(PatchOptions.Default.packageName) },
                    locked = packageNameLocked,
                    onLockClick = {
                        if (packageNameLocked) showPkgUnlockDialog = true else onLockPackageName()
                    },
                ) {
                    PackageNameStateLabel(
                        state = packageNameState,
                        modifier = Modifier.padding(start = 4.dp),
                    )
                }
            }

            val (integrations, patches) = remember(specs) { specs.partition { it.isIntegration } }

            if (integrations.isNotEmpty()) {
                PatchSelectionAccordion(
                    iconRes = R.drawable.ic_extension,
                    titleRes = R.string.patchopts_integrations_title,
                    descriptionRes = R.string.patchopts_integrations_desc,
                    specs = integrations,
                    enabledCount = integrations.count(isPatchEnabled),
                    totalCount = integrations.size,
                    isEnabled = isPatchEnabled,
                    onToggle = onTogglePatch,
                    lockState = patchLockState,
                    variantIndex = variantIndex,
                    onSelectVariant = onSelectVariant,
                    optionState = optionState,
                    modifier = Modifier.padding(top = 4.dp),
                )
            }

            PatchSelectionAccordion(
                iconRes = R.drawable.ic_healing,
                titleRes = R.string.patchopts_patches_title,
                descriptionRes = R.string.patchopts_patches_desc,
                specs = patches,
                enabledCount = patches.count(isPatchEnabled),
                totalCount = patches.size,
                isEnabled = isPatchEnabled,
                onToggle = onTogglePatch,
                lockState = patchLockState,
                variantIndex = variantIndex,
                onSelectVariant = onSelectVariant,
                optionState = optionState,
                modifier = if (integrations.isEmpty()) Modifier.padding(top = 4.dp) else Modifier,
            )

            IconSelectorOption(
                selectedIconId = selectedIconId,
                onSelectIcon = onSelectIcon,
            )

            if (isDevMode) {
                TextDivider(
                    text = stringResource(R.string.patchopts_divider_advanced),
                    modifier = Modifier.padding(top = 12.dp),
                )

                SwitchPatchOption(
                    icon = painterResource(R.drawable.ic_bug),
                    name = stringResource(R.string.patchopts_debuggable_title),
                    description = stringResource(R.string.patchopts_debuggable_desc),
                    value = debuggable,
                    onValueChange = setDebuggable,
                )

                IconPatchOption(
                    icon = painterResource(R.drawable.ic_music_note),
                    name = stringResource(R.string.patchopts_custom_tidal_apk_title),
                    description = stringResource(R.string.patchopts_custom_tidal_apk_desc),
                    modifier = Modifier.clickable(onClick = onSelectCustomTidalApk),
                ) {
                    FilledTonalButton(onClick = onSelectCustomTidalApk) {
                        Text(
                            text = customTidalApk?.version?.toString()
                                ?: stringResource(R.string.componentopts_selected_none)
                        )
                    }
                }

                IconPatchOption(
                    icon = painterResource(R.drawable.ic_extension),
                    name = stringResource(R.string.patchopts_custom_patches_title),
                    description = stringResource(R.string.patchopts_custom_patches_desc),
                    modifier = Modifier.clickable(onClick = onSelectCustomPatches),
                ) {
                    FilledTonalButton(onClick = onSelectCustomPatches) {
                        Text(
                            text = customPatches?.version?.toString()
                                ?: stringResource(R.string.componentopts_selected_none)
                        )
                    }
                }

                SwitchPatchOption(
                    icon = painterResource(R.drawable.ic_lock_open),
                    name = stringResource(R.string.patchopts_bypass_incompatible_title),
                    description = stringResource(R.string.patchopts_bypass_incompatible_desc),
                    value = bypassIncompatible,
                    onValueChange = setBypassIncompatible,
                )
            }

            Spacer(Modifier.weight(1f))

            FilledTonalButton(
                enabled = isConfigValid,
                onClick = onInstall,
                colors = ButtonDefaults.filledTonalButtonColors(
                    contentColor = MaterialTheme.colorScheme.primary,
                ),
                modifier = Modifier
                    .padding(bottom = 10.dp)
                    .align(Alignment.End),
            ) {
                Text(stringResource(R.string.action_install))
            }
        }
    }
}
private data class IconOption(val id: String, val drawableRes: Int)

private val ICON_OPTIONS = listOf(
    IconOption("alt1", R.drawable.ic_launcher_alt1),
    IconOption("alt2", R.drawable.ic_launcher_alt2),
    IconOption("alt3", R.drawable.ic_launcher_alt3),
    IconOption("alt4", R.drawable.ic_launcher_alt4),
    IconOption("alt5", R.drawable.ic_launcher_alt5),
    IconOption("alt6", R.drawable.ic_launcher_alt6),
    IconOption("alt7", R.drawable.ic_launcher_alt7),
)

@Composable
private fun IconSelectorOption(
    selectedIconId: String?,
    onSelectIcon: (String?) -> Unit,
) {
    Column(modifier = Modifier.padding(vertical = 8.dp)) {
        Text(
            text = stringResource(R.string.patchopts_icon_title),
            style = MaterialTheme.typography.titleMedium,
        )
        Text(
            text = stringResource(R.string.patchopts_icon_desc),
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(bottom = 8.dp, top = 2.dp),
        )
        LazyRow(
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            modifier = Modifier.fillMaxWidth(),
        ) {
            item {
                IconThumbnail(
                    icon = painterResource(R.drawable.ic_music_note),
                    label = stringResource(R.string.patchopts_icon_default),
                    selected = selectedIconId == null,
                    onClick = { onSelectIcon(null) },
                )
            }
            items(ICON_OPTIONS, key = { it.id }) { option ->
                IconThumbnail(
                    icon = painterResource(option.drawableRes),
                    label = null,
                    selected = selectedIconId == option.id,
                    onClick = { onSelectIcon(option.id) },
                )
            }
        }
    }
}

@Composable
private fun IconThumbnail(
    icon: androidx.compose.ui.graphics.painter.Painter,
    label: String?,
    selected: Boolean,
    onClick: () -> Unit,
) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.width(64.dp),
    ) {
        Box(
            modifier = Modifier
                .size(56.dp)
                .clip(RoundedCornerShape(16.dp))
                .border(
                    width = if (selected) 3.dp else 1.dp,
                    color = if (selected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outlineVariant,
                    shape = RoundedCornerShape(16.dp),
                )
                .clickable(onClick = onClick),
            contentAlignment = Alignment.Center,
        ) {
            Image(
                painter = icon,
                contentDescription = label,
                modifier = Modifier
                    .fillMaxSize()
                    .padding(if (label != null) 12.dp else 0.dp),
            )
        }
        if (label != null) {
            Text(
                text = label,
                style = MaterialTheme.typography.labelSmall,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 4.dp),
            )
        }
    }
}