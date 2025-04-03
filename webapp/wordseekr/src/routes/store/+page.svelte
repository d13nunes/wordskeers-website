<script lang="ts">
	import { goto } from '$app/navigation';
	import BalanceCard from '$lib/components/Store/BalanceCard.svelte';
	import StoreProductCard from '$lib/components/Store/StoreProductCard.svelte';

	function handleRemoveAds() {
		console.log('remove ads');
		goto('/store/remove-ads');
	}

	const products = [
		{
			id: '1',
			title: 'Starter Pack',
			detail: '300 coins',
			price: '0.99 $'
		},
		{
			id: '2',
			title: 'Popular Pack',
			detail: '1000 coins',
			price: '2.99 $',
			callout: 'Most Popular',
			isCalloutRed: false
		},
		{
			id: '3',
			title: 'Pro Pack',
			detail: '2000 coins',
			price: '4.99 $',
			callout: 'Best Value',
			isCalloutRed: true
		}
	];

	const rewardedAdProducts = [
		{
			id: '1',
			title: 'Get Free Coins',
			detail: '100 coins'
		}
	];

	function handleProductClick(id: string) {
		console.log(id);
	}
</script>

<div class="h-svh w-svw bg-slate-50 select-none">
	<div class="flex flex-col items-stretch gap-2 p-4">
		<span class="self-center text-2xl font-bold">Store</span>
		<BalanceCard balance={100} />
		<StoreProductCard
			title="Remove Ads"
			detail="Enjoy an ad-free experience"
			isIndicatorActive={true}
			onClick={handleRemoveAds}
			callout="Limited Time"
			isCalloutRed={true}
			isCalloutAnimating={true}
		/>

		<span class="text-xl font-bold">Coins</span>
		{#each products as product}
			<StoreProductCard
				title={product.title}
				detail={product.detail}
				price={product.price}
				callout={product.callout}
				isCalloutRed={product.isCalloutRed}
				onClick={() => handleProductClick(product.id)}
			/>
		{/each}
		{#each rewardedAdProducts as product}
			<StoreProductCard
				title={product.title}
				detail={product.detail}
				onClick={() => handleProductClick(product.id)}
			/>
		{/each}
	</div>
</div>
